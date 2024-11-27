<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    String userId = request.getParameter("userId");
    String password = request.getParameter("password");
    String role = "";
    String error = null;

    if (userId != null && password != null) {
        try {
            // 데이터베이스 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

            // 사용자 확인 쿼리
            String sql = 
                "SELECT 'student' as role FROM Students WHERE student_id = ? AND student_password = ? " +
                "UNION " +
                "SELECT 'teacher' as role FROM Professors WHERE professor_id = ? AND professor_password = ?";
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, password);
            pstmt.setString(3, userId);
            pstmt.setString(4, password);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                role = rs.getString("role");

                // 역할에 따라 대시보드로 이동
                if ("student".equals(role)) {
                    response.sendRedirect("student/dashboard.jsp?userId=" + userId + "&role=" + role);
                } else if ("teacher".equals(role)) {
                    response.sendRedirect("teacher/dashboard.jsp?userId=" + userId + "&role=" + role);
                }
            } else {
                error = "ID 또는 비밀번호가 잘못되었습니다.";
            }
            conn.close();
        } catch (Exception e) {
            error = "데이터베이스 연결 오류: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <div class="container">
        <h1>로그인</h1>
        <form action="login.jsp" method="post">
            <label for="userId">사용자 ID</label>
            <input type="text" id="userId" name="userId" required>

            <label for="password">비밀번호</label>
            <input type="password" id="password" name="password" required>

            <button type="submit">로그인</button>
        </form>
        <% if (error != null) { %>
            <p style="color: red;"><%= error %></p>
        <% } %>
    </div>
</body>
</html>
