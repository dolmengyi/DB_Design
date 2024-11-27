<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    String userId = request.getParameter("userId");
    String role = request.getParameter("role");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String error = null;
    String success = null;
    List<Map<String, String>> classList = new ArrayList<>();

    // 강의 목록 동적 로딩
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/edubridge";
        conn = DriverManager.getConnection(url, "root", "2189");

        // 학생이 수강 중인 강의명 로드
        String classQuery = "SELECT c.class_id, c.class_name FROM classes c " +
                            "JOIN students s ON c.class_id = s.class_id " +
                            "WHERE s.student_id = ?";
        pstmt = conn.prepareStatement(classQuery);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();

        // 데이터를 리스트로 저장
        while (rs.next()) {
            Map<String, String> classData = new HashMap<>();
            classData.put("class_id", rs.getString("class_id"));
            classData.put("class_name", rs.getString("class_name"));
            classList.add(classData);
        }

        rs.close();
        pstmt.close();

    } catch (Exception e) {
        error = "데이터베이스 연결 오류: " + e.getMessage();
    }

    // 저장 버튼 클릭 시 로직 처리
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String selectedClassId = request.getParameter("class_id");
        String feedbackRating = request.getParameter("feedback_rating");

        if (selectedClassId != null && feedbackRating != null) {
        	try {
        	    // 트랜잭션 시작
        	    conn.setAutoCommit(false);

        	    // 기존 피드백 확인
        	    String checkQuery = "SELECT feedback_id FROM classfeedback WHERE student_id = ? AND class_id = ?";
        	    pstmt = conn.prepareStatement(checkQuery);
        	    pstmt.setString(1, userId);
        	    pstmt.setInt(2, Integer.parseInt(selectedClassId));
        	    rs = pstmt.executeQuery();

        	    if (rs.next()) {
        	        // 기존 피드백 업데이트
        	        String updateQuery = "UPDATE classfeedback SET feedback_rating = ? WHERE student_id = ? AND class_id = ?";
        	        pstmt = conn.prepareStatement(updateQuery);
        	        pstmt.setString(1, feedbackRating);
        	        pstmt.setString(2, userId);
        	        pstmt.setInt(3, Integer.parseInt(selectedClassId));
        	        pstmt.executeUpdate();
        	        success = "피드백이 성공적으로 업데이트되었습니다.";
        	    } else {
        	        // 새 피드백 삽입
        	        String insertQuery = "INSERT INTO classfeedback (student_id, class_id, feedback_rating) VALUES (?, ?, ?)";
        	        pstmt = conn.prepareStatement(insertQuery);
        	        pstmt.setString(1, userId);
        	        pstmt.setInt(2, Integer.parseInt(selectedClassId));
        	        pstmt.setString(3, feedbackRating);
        	        pstmt.executeUpdate();
        	        success = "피드백이 성공적으로 저장되었습니다.";
        	    }

        	    // 트랜잭션 커밋
        	    conn.commit();
        	} catch (Exception e) {
        	    // 오류 발생 시 롤백
        	    if (conn != null) {
        	        try {
        	            conn.rollback();
        	        } catch (SQLException rollbackEx) {
        	            rollbackEx.printStackTrace();
        	        }
        	    }
        	    error = "피드백 저장 오류: " + e.getMessage();
        	    e.printStackTrace();
        	} finally {
        	    try {
        	        if (pstmt != null) pstmt.close();
        	        if (conn != null) conn.close();
        	    } catch (SQLException e) {
        	        e.printStackTrace();
        	    }
        	}

        } else {
            error = "모든 입력 값을 채워주세요.";
        }
    }

    try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학생 피드백</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
<div class="container">
    <h1>학생 피드백</h1>
    <% if (error != null) { %>
        <p style="color: red;"><%= error %></p>
    <% } %>
    <% if (success != null) { %>
        <p style="color: green;"><%= success %></p>
    <% } %>
    <form method="post">
        <table>
            <tr>
                <th>강의명</th>
                <td>
                    <select name="class_id" required>
                        <option value="">강의를 선택하세요</option>
                        <% for (Map<String, String> classData : classList) { %>
                            <option value="<%= classData.get("class_id") %>"><%= classData.get("class_name") %></option>
                        <% } %>
                    </select>
                </td>
            </tr>
            <tr>
                <th>평가 선택</th>
                <td>
                    <label><input type="radio" name="feedback_rating" value="불만족" required> 불만족</label>
                    <label><input type="radio" name="feedback_rating" value="보통"> 보통</label>
                    <label><input type="radio" name="feedback_rating" value="만족"> 만족</label>
                </td>
            </tr>
        </table>
        <button type="submit">저장</button>
    </form>
    <!-- 뒤로가기 및 로그아웃 -->
    <form action="dashboard.jsp" method="get" style="margin-top: 20px;">
        <input type="hidden" name="userId" value="<%= userId %>">
        <input type="hidden" name="role" value="<%= role %>">
        <button type="submit">뒤로가기</button>
    </form>
    <form action="../login.jsp" method="get" style="margin-top: 10px;">
        <button type="submit" class="logout-button">로그아웃</button>
    </form>
</div>
</body>
</html>
