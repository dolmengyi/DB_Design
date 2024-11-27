<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    String homeworkId = request.getParameter("homework_id");
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");
    String error = null;

    // Check if homework_id is null or empty
    if (homeworkId == null || homeworkId.trim().isEmpty()) {
%>
        <script>
            alert("삭제하려는 과제 ID가 전달되지 않았습니다. 다시 시도해주세요.");
            history.back();
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

        // 트랜잭션 시작
        conn.setAutoCommit(false);

        // 과제가 해당 학생의 것인지 확인
        String validateQuery = "SELECT COUNT(*) FROM HomeworkLogs WHERE homework_id = ? AND student_id = ?";
        pstmt = conn.prepareStatement(validateQuery);
        pstmt.setInt(1, Integer.parseInt(homeworkId));
        pstmt.setString(2, userId);
        ResultSet rs = pstmt.executeQuery();
        rs.next();

        if (rs.getInt(1) == 1) {
            pstmt.close(); // Close the previous PreparedStatement

            // 과제 삭제 쿼리
            String deleteQuery = "DELETE FROM HomeworkLogs WHERE homework_id = ?";
            pstmt = conn.prepareStatement(deleteQuery);
            pstmt.setInt(1, Integer.parseInt(homeworkId));
            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                // 삭제 성공 시 트랜잭션 커밋
                conn.commit();
                response.sendRedirect("student-homework.jsp?userId=" + userId + "&role=" + role);
            } else {
                // 삭제 실패 시 롤백
                conn.rollback();
                error = "과제 삭제에 실패했습니다.";
            }
        } else {
            // 삭제할 과제가 없거나 권한이 없는 경우 롤백
            conn.rollback();
            error = "삭제하려는 과제가 존재하지 않거나 권한이 없습니다.";
        }
    } catch (NumberFormatException e) {
        error = "삭제하려는 과제 ID가 올바르지 않습니다.";
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
        }
    } catch (Exception e) {
        error = "삭제 중 오류가 발생했습니다: " + e.getMessage();
        e.printStackTrace();
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
        }
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    if (error != null) {
%>
        <script>
            alert("<%= error %>");
            history.back();
        </script>
<%
    }
%>
