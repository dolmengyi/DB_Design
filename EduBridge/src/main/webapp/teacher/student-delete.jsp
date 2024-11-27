<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 전달받은 파라미터
    String studentId = request.getParameter("student_id");
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");
    String message = "";

    if (studentId != null && !studentId.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // 데이터베이스 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

            // 권한 확인: 관리자(admin) 또는 담당 교수만 삭제 가능
            boolean canDelete = false;

            if (role != null && role.equals("admin")) {
                canDelete = true; // 관리자는 무조건 허용
            } else if (role != null && role.equals("teacher")) {
                // 담당 반 확인
                String checkClassSql = "SELECT c.class_id FROM students s JOIN classes c ON s.class_id = c.class_id WHERE s.student_id = ?";
                pstmt = conn.prepareStatement(checkClassSql);
                pstmt.setString(1, studentId);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    String classId = rs.getString("class_id");

                    // 로그인 사용자가 담당하는 반인지 확인
                    String checkTeacherSql = "SELECT 1 FROM professors WHERE professor_id = ? AND EXISTS (SELECT 1 FROM classes WHERE professor_id = ? AND class_id = ?)";
                    PreparedStatement teacherPstmt = conn.prepareStatement(checkTeacherSql);
                    teacherPstmt.setString(1, userId);
                    teacherPstmt.setString(2, userId);
                    teacherPstmt.setString(3, classId);

                    ResultSet teacherRs = teacherPstmt.executeQuery();
                    if (teacherRs.next()) {
                        canDelete = true;
                    }

                    teacherRs.close();
                    teacherPstmt.close();
                }

                rs.close();
                pstmt.close();
            }

            if (canDelete) {
                // 학생 삭제
                String deleteSql = "DELETE FROM students WHERE student_id = ?";
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setString(1, studentId);

                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    message = "학생이 성공적으로 삭제되었습니다.";
                } else {
                    message = "학생 삭제에 실패하였습니다.";
                }
            } else {
                message = "학생 삭제 권한이 없습니다.";
            }
        } catch (Exception e) {
            message = "데이터베이스 오류: " + e.getMessage();
        } finally {
            // 리소스 정리
            if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    } else {
        message = "학생 ID가 누락되었습니다.";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학생 삭제</title>
    <script>
        alert("<%= message %>");
        window.location.href = "student-list.jsp?userId=<%= userId %>&role=<%= role %>";
    </script>
</head>
<body>
</body>
</html>
