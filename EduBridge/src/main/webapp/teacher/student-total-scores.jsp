<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>성적 관리</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
<div class="container">
    <h1>성적 관리</h1>
    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String userId = request.getParameter("userId");
        String role = request.getParameter("role");

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

            // 현재 교수의 담당 과목 가져오기
            String subjectQuery = "SELECT class_id FROM classes WHERE professor_id = ?";
            pstmt = conn.prepareStatement(subjectQuery);
            pstmt.setString(1, userId);
            ResultSet classRs = pstmt.executeQuery();

            StringBuilder classIds = new StringBuilder();
            while (classRs.next()) {
                if (classIds.length() > 0) {
                    classIds.append(",");
                }
                classIds.append(classRs.getInt("class_id"));
            }

            if (classIds.length() == 0) {
                throw new Exception("담당 과목이 없습니다.");
            }

            // 학생 성적 조회
            String query = "SELECT s.student_id, s.student_name, " +
               "  COALESCE(attendance_score.attendance_score, 0) AS attendance_score, " +
               "  AVG(hw.grade) AS homework_score, " +
               "  AVG(el.score) AS exam_score " +
               "FROM students s " +
               "LEFT JOIN ( " +
               "    SELECT student_id, " +
               "           SUM(CASE " +
               "                 WHEN attendance_status = 'Present' THEN 100 " +
               "                 WHEN attendance_status = 'Late' THEN 50 " +
               "                 WHEN attendance_status = 'Absent' THEN 0 " +
               "                 ELSE 0 " +
               "               END) AS attendance_score " +
               "    FROM attendancelogs " +
               "    GROUP BY student_id " +
               ") AS attendance_score ON s.student_id = attendance_score.student_id " +
               "LEFT JOIN homeworkLogs hw ON s.student_id = hw.student_id AND s.class_id = hw.class_id " +
               "LEFT JOIN examLogs el ON s.student_id = el.student_id AND s.class_id = el.class_id " +
               "WHERE s.class_id IN (" + classIds + ") " +
               "GROUP BY s.student_id, s.student_name " +
               "ORDER BY (attendance_score.attendance_score * 0.2 + " +
               "          AVG(hw.grade) * 0.3 + AVG(el.score) * 0.5) DESC";

            
            
            pstmt = conn.prepareStatement(query);
            rs = pstmt.executeQuery();
    %>
    <table>
        <thead>
            <tr>
                <th>순위</th>
                <th>학생 ID</th>
                <th>이름</th>
                <th>출석 점수</th>
                <th>과제 점수</th>
                <th>시험 점수</th>
                <th>학점</th>
            </tr>
        </thead>
        <tbody>
        <%
            int rank = 1;
            while (rs.next()) {
                String studentId = rs.getString("student_id");
                String studentName = rs.getString("student_name");
                int attendanceScore = rs.getInt("attendance_score");
                double homeworkScore = rs.getDouble("homework_score");
                double examScore = rs.getDouble("exam_score");

                // 종합 점수 계산
                double totalScore = (attendanceScore * 0.2) + (homeworkScore * 0.3) + (examScore * 0.5);
                String grade;
                if (totalScore >= 80) {
                    grade = "A";
                } else if (totalScore >= 70) {
                    grade = "B";
                } else if (totalScore >= 60) {
                    grade = "C";
                } else if (totalScore >= 50) {
                    grade = "D";
                } else {
                    grade = "F";
                }
        %>
            <tr>
                <td><%= rank++ %></td>
                <td><%= studentId %></td>
                <td><%= studentName %></td>
                <td><%= attendanceScore %></td>
                <td><%= homeworkScore %></td>
                <td><%= examScore %></td>
                <td><%= grade %></td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
    <%
        } catch (Exception e) {
            out.println("<p style='color: red;'>데이터를 불러오는 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    %>
    <form action="student-scores.jsp" method="get">
        <input type="hidden" name="userId" value="<%= userId %>">
        <input type="hidden" name="role" value="<%= role %>">
        <button type="submit" class="back-button">뒤로가기</button>
    </form>
    <!-- 로그아웃 버튼 -->
    <form action="../login.jsp" method="get" style="margin-top: 10px;">
        <button type="submit" class="logout-button">로그아웃</button>
    </form>
</div>
</body>
</html>
