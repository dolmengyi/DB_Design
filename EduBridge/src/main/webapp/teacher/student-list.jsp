<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 데이터베이스 연결 설정
    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = "jdbc:mysql://localhost:3306/edubridge";
    String dbUser = "root";
    String dbPassword = "2189";
    Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);

    // 로그인에서 전달된 userId와 role 변수 가져오기
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");

    // 담당 반 ID 정보 조회
    String classId = "";
    String error = null;
    try {
        // professors와 classes 테이블을 조인하여 반 ID 조회
        String professorSql = "SELECT c.class_id " +
                              "FROM professors p " +
                              "JOIN classes c ON p.Professor_id = c.Professor_id " +
                              "WHERE p.Professor_id = ?";
        PreparedStatement professorPstmt = conn.prepareStatement(professorSql);
        professorPstmt.setString(1, userId);
        ResultSet professorRs = professorPstmt.executeQuery();

        if (professorRs.next()) {
            classId = professorRs.getString("class_id"); // 담당 반 ID 가져오기
        } else {
            error = "교수가 담당하는 반 정보를 찾을 수 없습니다.";
        }
        professorRs.close();
        professorPstmt.close();
    } catch (Exception e) {
        error = "데이터베이스 오류: " + e.getMessage();
    }

    // 학생 목록 조회
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    if (error == null && !classId.isEmpty()) {
        try {
            // students 테이블에서 class_id로 학생 목록 조회
            String studentSql = "SELECT student_id, student_name, student_phone_number " +
                                "FROM students WHERE class_id = ?";
            pstmt = conn.prepareStatement(studentSql);
            pstmt.setString(1, classId); // 반 ID로 조회
            rs = pstmt.executeQuery();
        } catch (Exception e) {
            error = "학생 목록을 조회하는 중 오류가 발생했습니다: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학생 목록</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
    <div class="container">
        <h1>학생 목록</h1>

        <!-- 오류 메시지 출력 -->
        <% if (error != null) { %>
            <p style="color: red;"><%= error %></p>
        <% } %>

        <!-- 학생 목록 -->
        <table>
            <thead>
                <tr>
                    <th>학생 ID</th>
                    <th>이름</th>
                    <th>전화번호</th>
                    <th>삭제</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    if (rs != null) {
                        boolean hasData = false;
                        while (rs.next()) {
                            hasData = true;
                %>
                <tr>
                    <td><%= rs.getString("student_id") %></td>
                    <td><%= rs.getString("student_name") %></td>
                    <td><%= rs.getString("student_phone_number") %></td>
                    <td>
                        <form action="student-delete.jsp" method="get" style="margin: 0;">
                            <input type="hidden" name="student_id" value="<%= rs.getString("student_id") %>">
                            <input type="hidden" name="userId" value="<%= userId %>">
                            <input type="hidden" name="role" value="<%= role %>">
                            <button type="submit">삭제</button>
                        </form>
                    </td>
                </tr>
                <% 
                        }
                        if (!hasData) {
                %>
                <tr>
                    <td colspan="4">조회된 학생 정보가 없습니다.</td>
                </tr>
                <% 
                        }
                    } else { 
                %>
                <tr>
                    <td colspan="4">학생 목록을 불러오는 중 오류가 발생했습니다.</td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <!-- 버튼 컨테이너 -->
        <div style="margin-bottom: 20px; display: flex; gap: 10px;">
            <form action="student-add.jsp" method="get" style="margin: 0;">
                <input type="hidden" name="userId" value="<%= userId %>">
                <input type="hidden" name="role" value="<%= role %>">
                <button type="submit" class="add-button">학생 추가</button>
            </form>

            <form action="dashboard.jsp" method="get" style="margin: 0;">
                <input type="hidden" name="userId" value="<%= userId %>">
                <input type="hidden" name="role" value="<%= role %>">
                <button type="submit" class="back-button">뒤로가기</button>
            </form>
        </div>

        <!-- 로그아웃 버튼 -->
        <form action="../login.jsp" method="get" style="margin-top: 10px;">
            <button type="submit" class="logout-button">로그아웃</button>
        </form>
    </div>
</body>
</html>
<%
    // 자원 반환
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();
    conn.close();
%>
