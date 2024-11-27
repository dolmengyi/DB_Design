<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // login.jsp에서 전달된 사용자 ID와 역할 가져오기
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");

    // 데이터베이스 연결 변수
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 에러 메시지
    String error = null;

    try {
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

        // 학생의 과제 로그와 관련 과목 이름 조회
        String sql = "SELECT h.homework_id AS homework_log_id, " +
                     "       h.file_name, " +
                     "       c.class_name " +
                     "FROM homeworklogs h " +
                     "JOIN classes c ON h.class_id = c.class_id " +
                     "WHERE h.student_id = ? " +
                     "ORDER BY h.homework_id ASC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();
    } catch (Exception e) {
        error = "데이터베이스 연결 오류: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>과제 목록</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
    <div class="container">
        <h1>과제 목록</h1>
        <% if (error != null) { %>
            <div class="box">
                <p style="color: red;"><%= error %></p>
            </div>
        <% } else { %>
            <div class="box">
                <!-- 과제 목록 테이블 -->
                <table>
                    <thead>
                        <tr>
                            <th>과제 ID</th>
                            <th>과목 이름</th>
                            <th>파일 이름</th>
                            <th>삭제</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% while (rs.next()) { %>
                            <tr>
                                <td><%= rs.getInt("homework_log_id") %></td>
                                <td><%= rs.getString("class_name") %></td>
                                <td><%= rs.getString("file_name") %></td>
                                <td>
                                    <!-- 과제 삭제 버튼 -->
                                    <form action="student-homework-delete.jsp" method="post" style="display: inline;">
                                        <input type="hidden" name="homework_id" value="<%= rs.getInt("homework_log_id") %>">
                                        <input type="hidden" name="userId" value="<%= userId %>">
                                        <input type="hidden" name="role" value="<%= role %>">
                                        <button type="submit">삭제</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>

                <!-- 과제 업로드 버튼 -->
                <form action="student-homework-upload.jsp" method="get" style="display: inline-block;">
                    <input type="hidden" name="userId" value="<%= userId %>">
                    <input type="hidden" name="role" value="<%= role %>">
                    <button type="submit">업로드</button>
                </form>

                <!-- 뒤로가기 버튼 -->
                <form action="dashboard.jsp" method="get" style="display: inline-block;">
                    <input type="hidden" name="userId" value="<%= userId %>">
                    <input type="hidden" name="role" value="<%= role %>">
                    <button type="submit">뒤로가기</button>
                </form>
            </div>
        <% } %>
        <!-- 로그아웃 버튼 -->
        <form action="../login.jsp" method="get" style="margin: 0;">
            <button type="submit" class="logout-button">로그아웃</button>
        </form>
    </div>
</body>
</html>
<%
    // 리소스 닫기
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
