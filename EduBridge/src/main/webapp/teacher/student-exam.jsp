<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학생 시험 점수 관리</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
<div class="container">
    <h1>학생 시험 점수 관리</h1>

    <%
        // 데이터베이스 연결
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String userId = request.getParameter("userId");
        String role = request.getParameter("role");
        String message = request.getParameter("message");

        if (userId == null || role == null || userId.trim().isEmpty() || role.trim().isEmpty()) {
    %>
        <p>사용자 정보가 올바르지 않습니다. 다시 로그인해주세요.</p>
        <form action="../login.jsp" method="get">
            <button type="submit">로그인 화면으로</button>
        </form>
    <%
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/edubridge";
            conn = DriverManager.getConnection(url, "root", "2189");

            // 교수가 담당하는 전체 학생의 시험 정보 조회 쿼리
            String query = "SELECT s.student_id, s.student_name, " +
                           "MAX(CASE WHEN e.exam_type = 'Midterm' THEN e.score ELSE NULL END) AS midterm_score, " +
                           "MAX(CASE WHEN e.exam_type = 'Final' THEN e.score ELSE NULL END) AS final_score " +
                           "FROM Students s " +
                           "JOIN Classes c ON s.class_id = c.class_id " +
                           "LEFT JOIN ExamLogs e ON s.student_id = e.student_id AND e.professor_id = ? " +
                           "WHERE c.professor_id = ? " +
                           "GROUP BY s.student_id, s.student_name " +
                           "ORDER BY s.student_id";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, userId);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();
    %>

    <table>
        <thead>
        <tr>
            <th>학생 ID</th>
            <th>학생 이름</th>
            <th>중간고사 점수</th>
            <th>기말고사 점수</th>
            <th>수정</th>
        </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
                String studentId = rs.getString("student_id");
                String studentName = rs.getString("student_name");
                String midtermScore = rs.getString("midterm_score") != null ? rs.getString("midterm_score") : "미입력";
                String finalScore = rs.getString("final_score") != null ? rs.getString("final_score") : "미입력";
        %>
        <tr>
            <td><%= studentId %></td>
            <td><%= studentName %></td>
            <td>
                <form action="student-exam.jsp" method="post" style="display: inline;">
                    <input type="hidden" name="userId" value="<%= userId %>">
                    <input type="hidden" name="role" value="<%= role %>">
                    <input type="hidden" name="studentId" value="<%= studentId %>">
                    <input type="number" name="newScoreMidterm" value="<%= midtermScore.equals("미입력") ? "" : midtermScore %>" min="0" max="100" required>
            </td>
            <td>
                <input type="number" name="newScoreFinal" value="<%= finalScore.equals("미입력") ? "" : finalScore %>" min="0" max="100" required>
            </td>
            <td>
                <button type="submit">수정</button>
                </form>
            </td>
        </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <%
        // 점수 업데이트 처리
        // 점수 업데이트 처리
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String studentId = request.getParameter("studentId");
    String newMidtermScore = request.getParameter("newScoreMidterm");
    String newFinalScore = request.getParameter("newScoreFinal");

    if (studentId != null) {
        try {
            conn.setAutoCommit(false); // 트랜잭션 시작

            // 중간고사 점수 수정
            if (newMidtermScore != null && !newMidtermScore.trim().isEmpty()) {
                String updateMidtermQuery = "INSERT INTO ExamLogs (student_id, class_id, professor_id, exam_type, score) " +
                                            "VALUES (?, (SELECT class_id FROM Students WHERE student_id = ?), ?, 'Midterm', ?) " +
                                            "ON DUPLICATE KEY UPDATE score = ?";
                pstmt = conn.prepareStatement(updateMidtermQuery);
                pstmt.setString(1, studentId);
                pstmt.setString(2, studentId);
                pstmt.setString(3, userId);
                pstmt.setInt(4, Integer.parseInt(newMidtermScore));
                pstmt.setInt(5, Integer.parseInt(newMidtermScore));
                pstmt.executeUpdate();
            }

            // 기말고사 점수 수정
            if (newFinalScore != null && !newFinalScore.trim().isEmpty()) {
                String updateFinalQuery = "INSERT INTO ExamLogs (student_id, class_id, professor_id, exam_type, score) " +
                                          "VALUES (?, (SELECT class_id FROM Students WHERE student_id = ?), ?, 'Final', ?) " +
                                          "ON DUPLICATE KEY UPDATE score = ?";
                pstmt = conn.prepareStatement(updateFinalQuery);
                pstmt.setString(1, studentId);
                pstmt.setString(2, studentId);
                pstmt.setString(3, userId);
                pstmt.setInt(4, Integer.parseInt(newFinalScore));
                pstmt.setInt(5, Integer.parseInt(newFinalScore));
                pstmt.executeUpdate();
            }

            conn.commit(); // 트랜잭션 커밋
            response.sendRedirect("student-exam.jsp?userId=" + userId + "&role=" + role + "&message=수정이 완료되었습니다.");

        } catch (Exception e) {
            conn.rollback(); // 오류 발생 시 롤백
            response.sendRedirect("student-exam.jsp?userId=" + userId + "&role=" + role + "&message=수정 중 오류가 발생했습니다.");
            e.printStackTrace();
        } finally {
            conn.setAutoCommit(true); // 트랜잭션 종료 후 자동 커밋 모드로 복구
        }
    }
}

    %>

    <%
        } catch (Exception e) {
            out.println("<p>오류: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    %>

    <!-- 뒤로가기 및 로그아웃 버튼 -->
    <form action="student-scores.jsp" method="get">
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
