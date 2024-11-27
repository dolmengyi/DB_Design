<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    String professorId = request.getParameter("userId");
    String role = request.getParameter("role");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String error = null;

    try {
        // 데이터베이스 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

        // 피드백 정보 조회 SQL
        String sql = "SELECT c.class_name, " +
                     "SUM(CASE WHEN cf.feedback_rating = '불만족' THEN 1 ELSE 0 END) AS 불만족, " +
                     "SUM(CASE WHEN cf.feedback_rating = '보통' THEN 1 ELSE 0 END) AS 보통, " +
                     "SUM(CASE WHEN cf.feedback_rating = '만족' THEN 1 ELSE 0 END) AS 만족 " +
                     "FROM classfeedback cf " +
                     "JOIN classes c ON cf.class_id = c.class_id " +
                     "WHERE c.professor_id = ? " +  // 교수 ID를 기준으로 필터링
                     "GROUP BY c.class_name";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, professorId);
        rs = pstmt.executeQuery();
    } catch (Exception e) {
        error = "데이터베이스 오류: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>교수 피드백 조회</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
    <div class="container">
        <% if (error != null) { %>
            <div class="box">
                <p style="color: red; font-weight: bold; text-align: center;"><%= error %></p>
            </div>
        <% } else { %>
            <h1>학생 피드백</h1>
            <table>
                <thead>
                    <tr>
                        <th>강의명</th>
                        <th>불만족</th>
                        <th>보통</th>
                        <th>만족</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        boolean hasData = false;
                        while (rs.next()) { 
                            hasData = true;
                    %>
                        <tr>
                            <td><%= rs.getString("class_name") %></td>
                            <td><%= rs.getInt("불만족") %></td>
                            <td><%= rs.getInt("보통") %></td>
                            <td><%= rs.getInt("만족") %></td>
                        </tr>
                    <% } %>
                    <% if (!hasData) { %>
                        <tr>
                            <td colspan="4" style="text-align: center;">피드백 정보가 없습니다.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>

        <!-- 뒤로가기 및 로그아웃 -->
        <form action="dashboard.jsp" method="get" style="margin-top: 20px;">
            <input type="hidden" name="userId" value="<%= professorId %>">
            <input type="hidden" name="role" value="<%= role %>">
            <button type="submit">뒤로가기</button>
        </form>
        <form action="../login.jsp" method="get" style="margin-top: 10px;">
            <button type="submit" class="logout-button">로그아웃</button>
        </form>
    </div>
</body>
</html>
<%
    // 자원 정리
    try { if (rs != null) rs.close(); } catch (Exception e) { e.printStackTrace(); }
    try { if (pstmt != null) pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
    try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
%>
