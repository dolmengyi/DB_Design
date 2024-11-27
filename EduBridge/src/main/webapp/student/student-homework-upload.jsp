<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>과제 업로드</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
<div class="container">
    <h1>과제 업로드</h1>
    <%
        // 전달받은 userId와 role 값을 확인
        String userId = request.getParameter("userId");
        String role = request.getParameter("role");
        String action = request.getParameter("action");
        String fileName = request.getParameter("file_name");
        String weekNumber = request.getParameter("week_number");

        // action 값 확인
        if ("upload".equalsIgnoreCase(action)) {
            if (fileName == null || fileName.trim().isEmpty() || weekNumber == null) {
                out.println("<p style='color:red;'>과제명과 주차를 입력하세요.</p>");
            } else {
                // 데이터베이스 연결 및 처리
                Connection conn = null;
                PreparedStatement pstmt = null;
                PreparedStatement classStmt = null;
                ResultSet rs = null;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    String url = "jdbc:mysql://localhost:3306/edubridge";
                    conn = DriverManager.getConnection(url, "root", "2189");

                    // 트랜잭션 시작
                    conn.setAutoCommit(false);

                    // 현재 사용자가 듣고 있는 수업의 class_id 가져오기
                    String classQuery = "SELECT class_id FROM students WHERE student_id = ?";
                    classStmt = conn.prepareStatement(classQuery);
                    classStmt.setString(1, userId);
                    rs = classStmt.executeQuery();

                    if (rs.next()) {
                        int classId = rs.getInt("class_id");

                        // HomeworkLogs 테이블에 과제 데이터 삽입
                        String query = "INSERT INTO HomeworkLogs (student_id, class_id, week_number, file_name) VALUES (?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(query);
                        pstmt.setString(1, userId); // 전달받은 userId 저장
                        pstmt.setInt(2, classId); // 현재 사용자의 class_id 저장
                        pstmt.setInt(3, Integer.parseInt(weekNumber)); // 선택한 주차 저장
                        pstmt.setString(4, fileName); // 입력받은 파일 이름 저장
                        pstmt.executeUpdate();

                        // 트랜잭션 커밋
                        conn.commit();
                        out.println("<p style='color:green;'>과제가 성공적으로 업로드되었습니다.</p>");
                        response.sendRedirect("student-homework.jsp?userId=" + userId + "&role=" + role);
                    } else {
                        out.println("<p style='color:red;'>수업 정보를 찾을 수 없습니다.</p>");
                    }
                } catch (Exception e) {
                    // 오류 발생 시 롤백
                    if (conn != null) {
                        try {
                            conn.rollback();
                        } catch (SQLException rollbackEx) {
                            rollbackEx.printStackTrace();
                        }
                    }
                    out.println("<p style='color:red;'>업로드 중 문제가 발생했습니다. 다시 시도하세요.</p>");
                    e.printStackTrace();
                } finally {
                    try { if (rs != null) rs.close(); } catch (SQLException e) {}
                    try { if (classStmt != null) classStmt.close(); } catch (SQLException e) {}
                    try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
                    try { if (conn != null) conn.close(); } catch (SQLException e) {}
                }

            }
        } else if ("cancel".equalsIgnoreCase(action)) {
            // 취소 버튼 클릭 시 student-homework.jsp로 리다이렉트
            response.sendRedirect("student-homework.jsp?userId=" + userId + "&role=" + role);
        }
    %>
    <!-- 과제 업로드 폼 -->
    <form method="get" action="student-homework-upload.jsp">
        <input type="hidden" name="userId" value="<%= userId %>">
        <input type="hidden" name="role" value="<%= role %>">
        <table>
            <tr>
                <th>과제명</th>
                <td><input type="text" name="file_name" placeholder="파일 이름 입력" required></td>
            </tr>
            <tr>
                <th>주차</th>
                <td>
                    <select name="week_number" required>
                        <option value="1">1주차</option>
                        <option value="2">2주차</option>
                        <option value="3">3주차</option>
                    </select>
                </td>
            </tr>
        </table>
        <div>
            <button type="submit" name="action" value="upload">제출</button>
            <button type="submit" name="action" value="cancel">취소</button>
        </div>
    </form>
    <!-- 로그아웃 버튼 -->
    <form action="../login.jsp" method="get" style="margin: 0;">
        <button type="submit" class="logout-button">로그아웃</button>
    </form>
</div>
</body>
</html>
