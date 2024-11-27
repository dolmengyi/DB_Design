<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // 사용자 ID 및 역할 가져오기
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String error = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

        // 수업 조회 SQL
        String classesSql = "SELECT c.class_name, al.attendance_status, al.attendance_date " +
                            "FROM attendanceLogs al " +
                            "JOIN classes c ON al.class_id = c.class_id " +
                            "WHERE al.student_id = ?";

        // 성적 조회 SQL
        String scoresSql = "SELECT c.class_name, ex.exam_type, ex.score " +
                           "FROM examlogs ex " +
                           "JOIN classes c ON ex.class_id = c.class_id " +
                           "WHERE ex.student_id = ?";

        // 과제 점수 조회 SQL
        String assignmentsSql = "SELECT c.class_name, h.file_name, h.grade " +
                                "FROM homeworkLogs h " +
                                "JOIN classes c ON h.class_id = c.class_id " +
                                "WHERE h.student_id = ?";

        // 같은 과목 수강생 순위 조회 SQL
        String rankingSql = "SELECT " +
                            "st.student_id AS '학생 ID', " +
                            "c.class_name AS '과목 이름', " +
                            "SUM(ex.score) AS '총점', " +
                            "RANK() OVER (PARTITION BY c.class_id ORDER BY SUM(ex.score) DESC) AS '순위' " +
                            "FROM examlogs ex " +
                            "JOIN classes c ON ex.class_id = c.class_id " +
                            "JOIN students st ON ex.student_id = st.student_id " +
                            "WHERE c.class_id IN (SELECT class_id FROM students WHERE student_id = ?) " + // 현재 사용자가 수강 중인 과목만 필터링
                            "GROUP BY st.student_id, c.class_id, c.class_name " +
                            "ORDER BY c.class_name, 순위";

        pstmt = conn.prepareStatement(classesSql);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();

%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>전체 성적 조회</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
<div class="container">
    <h1>전체 성적 조회</h1>
    <% if (error != null) { %>
        <div class="error">
            <p style="color: red;"><%= error %></p>
        </div>
    <% } else { %>
        <div class="attendance-section">
            <h2>출석 조회</h2>
            <table>
                <thead>
                <tr>
                    <th>과목</th>
                    <th>출석 상태</th>
                    <th>날짜</th>
                </tr>
                </thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getString("class_name") %></td>
                        <td><%= rs.getString("attendance_status") %></td>
                        <td><%= rs.getDate("attendance_date") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <%
            pstmt.close();
            rs.close();

            // 과제 점수 데이터 조회
            pstmt = conn.prepareStatement(assignmentsSql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
        %>
		<br><br>
        <div class="assignments-section">
            <h2>과제 조회</h2>
            <table>
                <thead>
                <tr>
                    <th>과목</th>
                    <th>파일 이름</th>
                    <th>점수</th>
                </tr>
                </thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getString("class_name") %></td>
                        <td><%= rs.getString("file_name") %></td>
                        <td><%= rs.getObject("grade") == null ? "미제출" : rs.getInt("grade") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <%
            pstmt.close();
            rs.close();

            // 성적 데이터 조회
            pstmt = conn.prepareStatement(scoresSql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
        %>
		<br><br>
        <div class="scores-section">
            <h2>시험 조회</h2>
            <table>
                <thead>
                <tr>
                    <th>과목</th>
                    <th>시험 유형</th>
                    <th>점수</th>
                </tr>
                </thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getString("class_name") %></td>
                        <td><%= rs.getString("exam_type") %></td>
                        <td><%= rs.getInt("score") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        

        <%
            pstmt.close();
            rs.close();

            // 같은 과목 수강생 순위 조회
            pstmt = conn.prepareStatement(rankingSql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
        %>
		<br><br>
        <div class="rankings-section">
            <h2>수강생 순위</h2>
            <table>
                <thead>
                <tr>
                	<th>순위</th>
                    <th>학생 ID</th>
                    <th>과목 이름</th>
                    <th>총점</th>
                </tr>
                </thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr>
                    	<td><%= rs.getInt("순위") %></td>
                        <td><%= rs.getString("학생 ID") %></td>
                        <td><%= rs.getString("과목 이름") %></td>
                        <td><%= rs.getInt("총점") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    <% } %>

    <!-- 뒤로가기 및 로그아웃 버튼 -->
    <form action="dashboard.jsp" method="get">
        <input type="hidden" name="userId" value="<%= userId %>">
        <input type="hidden" name="role" value="<%= role %>">
        <button type="submit">뒤로가기</button>
    </form>
    <form action="../login.jsp" method="get">
        <button type="submit" class="logout-button">로그아웃</button>
    </form>

</div>
</body>
</html>
<%
    } catch (Exception e) {
        error = "데이터베이스 연결 오류: " + e.getMessage();
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
