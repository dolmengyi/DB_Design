<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // login.jsp에서 전달된 사용자 ID와 역할 가져오기
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");

    // 교수 정보를 저장할 변수
    String fullName = "";
    String subjectName = "";
    String error = null;

    if (userId != null && role != null) {
        try {
            // 데이터베이스 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

            // 교수 정보 조회
            String sql = "SELECT professor_full_name, professor_subject_name FROM Professors WHERE professor_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                fullName = rs.getString("professor_full_name");
                subjectName = rs.getString("professor_subject_name");
            } else {
                error = "교수 정보를 찾을 수 없습니다.";
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
    <title>교수 대시보드</title>
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
                <h1>안녕하세요 「<%= fullName %>」 교수님</h1>
            </div>
            <div class="box">
                <h2>나의 정보</h2>
                <table>
                    <tbody>
                        <tr>
                            <td><strong>이름</strong></td>
                            <td><%= fullName %></td>
                        </tr>
                        <tr>
                            <td><strong>담당 과목</strong></td>
                            <td><%= subjectName %></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="box">
                <h2>학생 정보 관리</h2>
                <table>
                    <tbody>
                        <tr>
                            <th>학생 관리</th>
                            <td><a href="student-list.jsp?userId=<%= userId %>&role=<%= role %>"><button>선택</button></a></td>
                        </tr>
                        <tr>
                            <th>성적 관리</th>
                            <td><a href="student-scores.jsp?userId=<%= userId %>&role=<%= role %>"><button>선택</button></a></td>
                        </tr>
                        <tr>
                                <th>강의 평가</th>
                                <td><a href="professor-feedback.jsp?userId=<%= userId %>&role=<%= role %>"><button>선택</button></a></td>
                            </tr>
                    </tbody>
                </table>
            </div>
        <% } %>
        <!-- 로그아웃 버튼 -->
        <form action="../login.jsp" method="get" style="margin-top: 10px;">
            <button type="submit" class="logout-button">로그아웃</button>
        </form>
    </div>
</body>
</html>
