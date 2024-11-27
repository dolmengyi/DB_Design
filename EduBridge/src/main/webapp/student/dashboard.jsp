<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // login.jsp에서 전달된 사용자 ID 및 역할 가져오기
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");

    // 사용자 정보를 저장할 변수
    String name = "";
    String classOrSubject = "";
    String phoneNumber = "";
    String error = null;

    if (userId != null && role != null) {
        try {
            // 데이터베이스 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

            String sql = "";

            // 역할에 따라 조회 쿼리 결정
            if ("student".equals(role)) {
                sql = "SELECT student_name, student_class_name, student_phone_number FROM Students WHERE student_id = ?";
            } else if ("teacher".equals(role)) {
                sql = "SELECT teacher_full_name AS student_name, teacher_subject_name AS student_class_name, '' AS student_phone_number FROM Teachers WHERE teacher_id = ?";
            }

            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                name = rs.getString("student_name");
                classOrSubject = rs.getString("student_class_name");
                phoneNumber = rs.getString("student_phone_number");
            } else {
                error = "사용자 정보를 찾을 수 없습니다.";
            }

            conn.close();
        } catch (Exception e) {
            error = "데이터베이스 오류: " + e.getMessage();
        }
    } else {
        error = "로그인 정보가 누락되었습니다.";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>대시보드</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
    <div class="container">
        <% if (error != null) { %>
            <div class="box">
                <p style="color: red; font-weight: bold; text-align: center;"><%= error %></p>
            </div>
        <% } else { %>
        	<div>
                <h1>안녕하세요 「<%= name %>」 학생</h1>
            </div>
            <div class="box">
                <h2>나의 정보</h2>
                <table>
                    <tr>
                        <th>이름</th>
                        <td><%= name %></td>
                    </tr>
                    <tr>
                        <th>아이디</th>
                        <td><%= userId %></td>
                    </tr>
                    <tr>
                        <th><%= "student".equals(role) ? "수업" : "담당 과목" %></th>
                        <td><%= classOrSubject %></td>
                    </tr>
                    <% if ("student".equals(role)) { %>
                        <tr>
                            <th>연락처</th>
                            <td><%= phoneNumber %></td>
                        </tr>
                    <% } %>
                </table>
            </div>

            <div class="box">
                <h2>학습 활동</h2>
                <table>
                    <tbody>
                        <% if ("student".equals(role)) { %>
                            <tr>
                                <th>과제 관리</th>
                                <td><a href="student-homework.jsp?userId=<%= userId %>&role=<%= role %>"><button>선택</button></a></td>
                            </tr>

                            <tr>
                                <th>성적 조회</th>
                                <td><a href="student-scores.jsp?userId=<%= userId %>&role=<%= role %>"><button>선택</button></a></td>
                            </tr>

                            <tr>
                                <th>강의 평가</th>
                                <td><a href="student-feedback.jsp?userId=<%= userId %>&role=<%= role %>"><button>선택</button></a></td>
                            </tr>
                        <% }  %>
                    </tbody>
                </table>
            </div>
        <% } %>
            <!-- 로그아웃 버튼 -->
	<form action="../login.jsp" method="get" style="margin: 0;">
    	<button type="submit" class="logout-button">로그아웃</button>
	</form>
    </div>
    
</body>
</html>
