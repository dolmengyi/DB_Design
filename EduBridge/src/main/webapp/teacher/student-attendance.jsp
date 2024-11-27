<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학생 출석 관리</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
<div class="container">
    <h1>학생 출석 관리</h1>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String userId = request.getParameter("userId");
        String role = request.getParameter("role");

        String selectedDate = request.getParameter("date"); // 선택된 날짜
        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate = "2024-11-01"; // 기본값: 특정 날짜
        }

        String selectedWeek = request.getParameter("week"); // 선택된 주차
        if (selectedWeek == null || selectedWeek.isEmpty()) {
            selectedWeek = "1"; // 기본값: 1주차
        }

        String filterStatus = request.getParameter("status"); // 선택된 상태 필터
        if (filterStatus == null) {
            filterStatus = "";
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/edubridge";
            conn = DriverManager.getConnection(url, "root", "2189");

            // 교수의 담당 과목에 해당하는 학생들만 조회
            String query = "SELECT al.attendance_date, al.attendance_week, al.student_id, s.student_name, al.attendance_status " +
                           "FROM AttendanceLogs al " +
                           "JOIN Students s ON al.student_id = s.student_id " +
                           "JOIN Classes c ON s.class_id = c.class_id " +
                           "JOIN Professors p ON c.Professor_id = p.Professor_id " +
                           "WHERE p.Professor_id = ? AND al.attendance_date = ? AND al.attendance_week = ? " +
                           (filterStatus.isEmpty() ? "" : "AND al.attendance_status = ?") +
                           " ORDER BY al.student_id";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, userId);
            pstmt.setString(2, selectedDate);
            pstmt.setString(3, selectedWeek);
            if (!filterStatus.isEmpty()) {
                pstmt.setString(4, filterStatus);
            }
            rs = pstmt.executeQuery();

            // 출석 상태 업데이트 처리
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String studentId = request.getParameter("studentId");
                String date = request.getParameter("date");
                String week = request.getParameter("week");
                String newStatus = request.getParameter("newStatus");

                if (studentId != null && date != null && week != null && newStatus != null) {
                    String updateQuery = "UPDATE AttendanceLogs " +
                                         "SET attendance_status = ? " +
                                         "WHERE student_id = ? AND attendance_date = ? AND attendance_week = ?";
                    pstmt = conn.prepareStatement(updateQuery);
                    pstmt.setString(1, newStatus);
                    pstmt.setString(2, studentId);
                    pstmt.setString(3, date);
                    pstmt.setString(4, week);
                    int updatedRows = pstmt.executeUpdate(); // 쿼리 실행

                    if (updatedRows > 0) {
                        out.println("<p style='color: green; font-weight: bold;'>출석 상태가 성공적으로 저장되었습니다.</p>");
                    } else {
                        out.println("<p style='color: red; font-weight: bold;'>출석 상태 저장에 실패했습니다.</p>");
                    }

                    response.sendRedirect("student-attendance.jsp?date=" + date + "&week=" + week + "&status=" + filterStatus +
                                          "&userId=" + userId + "&role=" + role);
                }
            }
    %>

    <!-- 날짜 및 주차 선택 -->
    <form action="student-attendance.jsp" method="get">
        <input type="hidden" name="userId" value="<%= userId %>">
        <input type="hidden" name="role" value="<%= role %>">
        
        <!-- 날짜 선택 -->
        <label for="date">날짜 선택:</label>
        <input type="date" name="date" id="date" value="<%= selectedDate %>" onchange="this.form.submit()">

        <!-- 주차 선택 -->
        <label for="week">주차 선택:</label>
        <select name="week" id="week" onchange="this.form.submit()">
            <% for (int i = 1; i <= 3; i++) { %>
                <option value="<%= i %>" <%= (String.valueOf(i).equals(selectedWeek)) ? "selected" : "" %>><%= i %>주차</option>
            <% } %>
        </select>

        <!-- 상태 필터 -->
        <label for="status">상태 선택:</label>
        <select name="status" id="status" onchange="this.form.submit()">
            <option value="" <%= filterStatus.isEmpty() ? "selected" : "" %>>전체</option>
            <option value="Present" <%= "Present".equals(filterStatus) ? "selected" : "" %>>출석</option>
            <option value="Late" <%= "Late".equals(filterStatus) ? "selected" : "" %>>지각</option>
            <option value="Absent" <%= "Absent".equals(filterStatus) ? "selected" : "" %>>결석</option>
        </select>
    </form>

    <!-- 학생 정보 테이블 -->
    <table>
        <thead>
        <tr>
            <th>날짜</th>
            <th>주차</th>
            <th>학생 ID</th>
            <th>학생 이름</th>
            <th>상태</th>
            <th>수정</th>
        </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
                String attendanceDate = rs.getString("attendance_date");
                String attendanceWeek = rs.getString("attendance_week");
                String studentId = rs.getString("student_id");
                String studentName = rs.getString("student_name");
                String attendanceStatus = rs.getString("attendance_status");
        %>
        <tr>
            <td><%= attendanceDate %></td>
            <td><%= attendanceWeek %></td>
            <td><%= studentId %></td>
            <td><%= studentName %></td>
            <td>
            <form action="student-attendance.jsp" method="post" style="margin: 0;">
                    <input type="hidden" name="userId" value="<%= userId %>">
                    <input type="hidden" name="role" value="<%= role %>">
                    <input type="hidden" name="studentId" value="<%= studentId %>">
                    <input type="hidden" name="date" value="<%= attendanceDate %>">
                    <input type="hidden" name="week" value="<%= attendanceWeek %>">
                    <select name="newStatus">
                        <option value="Present" <%= "Present".equals(attendanceStatus) ? "selected" : "" %>>출석</option>
                        <option value="Late" <%= "Late".equals(attendanceStatus) ? "selected" : "" %>>지각</option>
                        <option value="Absent" <%= "Absent".equals(attendanceStatus) ? "selected" : "" %>>결석</option>
                    </select>
            </td>
            <td>
                <button type="submit">수정</button>
            </form>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>

    <%
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>오류: " + e.getMessage() + "</p>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    %>

    <!-- 뒤로가기 및 로그아웃 -->
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
