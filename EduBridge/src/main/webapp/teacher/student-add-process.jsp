<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // 전달받은 폼 데이터
    String studentName = request.getParameter("student_name");
    String studentClassName = request.getParameter("student_class_name");
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");

    String message = null;

    // 데이터베이스 연결
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String classId = null;
    String studentId = null;

    try {
        // 드라이버 로드 및 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

        // class_name을 기반으로 class_id 조회
        String classSql = "SELECT class_id FROM classes WHERE class_name = ?";
        pstmt = conn.prepareStatement(classSql);
        pstmt.setString(1, studentClassName);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            classId = rs.getString("class_id");
        } else {
            message = "해당 반 정보를 찾을 수 없습니다.";
        }

        rs.close();
        pstmt.close();

        // 가장 큰 student_id 조회
        if (classId != null) {
            String idSql = "SELECT MAX(student_id) AS max_id FROM students WHERE student_id LIKE 'CSC-SN%'";
            pstmt = conn.prepareStatement(idSql);
            rs = pstmt.executeQuery();

            if (rs.next() && rs.getString("max_id") != null) {
                String maxId = rs.getString("max_id"); // 예: "CSC-SN25"
                // 정규식을 사용하여 숫자 부분만 추출
                String numericPart = maxId.replaceAll("\\D+", ""); // "25"
                int newId = Integer.parseInt(numericPart) + 1; // 26
                studentId = "CSC-SN" + String.format("%02d", newId); // "CSC-SN26"
            } else {
                studentId = "CSC-SN01"; // 초기 ID
            }

            rs.close();
            pstmt.close();

            // 학생 정보 삽입
            String sql = "INSERT INTO students (student_id, student_name, student_password, student_phone_number, student_class_name, class_id) " +
                         "VALUES (?, ?, '0000', '01012345678', ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setString(2, studentName);
            pstmt.setString(3, studentClassName);
            pstmt.setString(4, classId);

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                message = "학생 정보가 성공적으로 추가되었습니다.";
                // attendancelogs 테이블에 데이터 삽입
                String attendanceSql = "INSERT INTO attendancelogs (student_id, class_id, attendance_date, attendance_status, attendance_week) " +
                                        "VALUES (?, ?, '2024-11-01', 'Present', 1)";
                pstmt = conn.prepareStatement(attendanceSql);
                pstmt.setString(1, studentId);
                pstmt.setString(2, classId);
                
                int attendanceRows = pstmt.executeUpdate();
                if (attendanceRows > 0) {
                    message += "";
                } else {
                    message += " 출석 정보 추가에 실패했습니다.";
                }

            } else {
                message = "학생 정보 추가에 실패했습니다.";
            }
        }
    } catch (Exception e) {
        message = "오류가 발생했습니다: " + e.getMessage();
        e.printStackTrace();
    } finally {
        // 자원 반환
        if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학생 추가 결과</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
    <div class="container">
        <h1>학생 추가 결과</h1>
        <p><%= message %></p>
        <form action="student-list.jsp" method="get">
            <input type="hidden" name="userId" value="<%= userId %>">
            <input type="hidden" name="role" value="<%= role %>">
            <button type="submit" class="back-button">학생 목록으로 돌아가기</button>
        </form>
    </div>
</body>
</html>
