<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    String userId = request.getParameter("userId"); // 현재 사용자 ID
    String role = request.getParameter("role"); // 현재 역할 (교수 또는 학생)
    String selectedWeek = request.getParameter("week"); // 선택된 주차
    if (selectedWeek == null || selectedWeek.isEmpty()) {
        selectedWeek = "1"; // 기본값: 1주차
    }

    String error = null;
    String successMessage = null;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

     // 성적 입력/수정 처리
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String homeworkId = request.getParameter("homework_id");
            String studentId = request.getParameter("student_id");
            String grade = request.getParameter("grade");

            if (homeworkId != null && studentId != null && grade != null) {
                conn.setAutoCommit(false); // 트랜잭션 시작

                try {
                    String updateSql = "UPDATE HomeworkLogs " +
                                       "SET grade = ? " +
                                       "WHERE homework_id = ? AND student_id = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setInt(1, Integer.parseInt(grade));
                    pstmt.setString(2, homeworkId);
                    pstmt.setString(3, studentId);
                    int rowsAffected = pstmt.executeUpdate();

                    if (rowsAffected > 0) {
                        conn.commit(); // 트랜잭션 커밋
                        successMessage = "성적이 성공적으로 입력/수정되었습니다.";
                    } else {
                        conn.rollback(); // 트랜잭션 롤백
                        error = "성적 입력/수정에 실패했습니다.";
                    }
                } catch (Exception e) {
                    conn.rollback(); // 트랜잭션 롤백
                    error = "데이터베이스 오류: " + e.getMessage();
                    e.printStackTrace();
                } finally {
                    conn.setAutoCommit(true); // auto-commit 모드 복구
                }
            }
        }


        // 과제 조회 SQL
        String sql = "";
        if ("teacher".equals(role)) {
            sql = "SELECT h.homework_id, h.week_number, h.student_id, s.student_name, " +
                  "h.file_name, h.grade " +
                  "FROM HomeworkLogs h " +
                  "JOIN Students s ON h.student_id = s.student_id " +
                  "JOIN Classes c ON s.class_id = c.class_id " +
                  "JOIN Professors p ON c.Professor_id = p.Professor_id " +
                  "WHERE p.Professor_id = ? AND c.class_id = h.class_id AND h.week_number = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, Integer.parseInt(selectedWeek));
        } else if ("student".equals(role)) {
            sql = "SELECT h.homework_id, h.week_number, h.student_id, s.student_name, " +
                  "h.file_name, h.grade " +
                  "FROM HomeworkLogs h " +
                  "JOIN Students s ON h.student_id = s.student_id " +
                  "WHERE h.student_id = ? AND h.week_number = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, Integer.parseInt(selectedWeek));
        }

        rs = pstmt.executeQuery();
    } catch (Exception e) {
        error = "데이터베이스 오류: " + e.getMessage();
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>과제 관리</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
    <div class="container">
        <h1>과제 관리</h1>

        <!-- 주차 선택 -->
        <form action="student-homework.jsp" method="get">
            <label for="week">주차 선택:</label>
            <select name="week" id="week" onchange="this.form.submit()">
                <% for (int i = 1; i <= 3; i++) { %>
                    <option value="<%= i %>" <%= i == Integer.parseInt(selectedWeek) ? "selected" : "" %>>
                        <%= i %>주차
                    </option>
                <% } %>
            </select>
            <input type="hidden" name="userId" value="<%= userId %>">
            <input type="hidden" name="role" value="<%= role %>">
        </form>

        <% if (successMessage != null) { %>
            <p style="color: green;"><%= successMessage %></p>
        <% } %>
        <% if (error != null) { %>
            <p style="color: red;"><%= error %></p>
        <% } else { %>
            <table>
                <thead>
                    <tr>
                        <th>학생 ID</th>
                        <th>학생 이름</th>
                        <th>파일 이름</th>
                        <th>성적</th>
                        <th>성적 입력</th>
                    </tr>
                </thead>
                <tbody>
                    <% while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getString("student_id") %></td>
                        <td><%= rs.getString("student_name") %></td>
                        <td><%= rs.getString("file_name") %></td>
                        <td><%= rs.getObject("grade") == null ? "미입력" : rs.getInt("grade") %></td>
                        <td>
                            <!-- 성적 입력 -->
                            <form action="student-homework.jsp" method="post">
                                <input type="hidden" name="homework_id" value="<%= rs.getInt("homework_id") %>">
                                <input type="hidden" name="student_id" value="<%= rs.getString("student_id") %>">
                                <input type="hidden" name="userId" value="<%= userId %>">
                                <input type="hidden" name="role" value="<%= role %>">
                                <input type="number" name="grade" value="<%= rs.getObject("grade") == null ? "" : rs.getInt("grade") %>" min="0" max="100" required>
                                <button type="submit">입력</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>

        <!-- 뒤로가기 및 로그아웃 버튼 -->
        <div style="display: flex; justify-content: space-between; margin-top: 20px;">
            <!-- 뒤로가기 버튼 -->
            <form action="student-scores.jsp" method="get">
                <input type="hidden" name="userId" value="<%= userId %>">
                <input type="hidden" name="role" value="<%= role %>">
                <button type="submit" class="back-button">뒤로가기</button>
            </form>

            <!-- 로그아웃 버튼 -->
            <form action="../login.jsp" method="get">
                <button type="submit" class="logout-button">로그아웃</button>
            </form>
        </div>
    </div>
</body>
</html>
<%
    // 자원 반환
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();
    if (conn != null) conn.close();
%>
