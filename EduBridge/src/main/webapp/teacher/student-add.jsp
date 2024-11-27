<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // 전달받은 userId와 role
    String userId = request.getParameter("userId");
    String role = request.getParameter("role");
    String error = null;

    // 교수의 담당 과목 가져오기
    String subjectName = "";
    if (userId != null && role != null && role.equals("teacher")) {
        try {
            // 데이터베이스 연결
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/edubridge", "root", "2189");

            // 담당 과목 조회
            String sql = "SELECT Professor_subject_name FROM professors WHERE Professor_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                subjectName = rs.getString("Professor_subject_name");
            } else {
                error = "교수 정보를 찾을 수 없습니다.";
            }

            conn.close();
        } catch (Exception e) {
            error = "데이터베이스 오류: " + e.getMessage();
        }
    } else {
        error = "유효하지 않은 접근입니다.";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>학생 추가</title>
    <link rel="stylesheet" href="../css/styles.css">
</head>
<body>
    <div class="container">
        <% if (error != null) { %>
            <div class="box">
                <p style="color: red; font-weight: bold; text-align: center;"><%= error %></p>
            </div>
        <% } else { %>
            <div class="box">
                <h1>학생 추가</h1>
                <form action="student-add-process.jsp" method="post">
                    <input type="hidden" name="userId" value="<%= userId %>">
                    <input type="hidden" name="role" value="<%= role %>">
                    <div>
                        <label for="student_name">이름</label>
                        <input type="text" id="student_name" name="student_name" required>
                    </div>
                    <div>
                        <label>과목</label>
                        <input type="text" value="<%= subjectName %>" readonly>
                        <input type="hidden" name="student_class_name" value="<%= subjectName %>">
                    </div>
                    <button type="submit" class="add-button">등록</button>
                </form>
            </div>
        <% } %>

        <div style="display: flex; justify-content: space-between; margin-top: 20px;">
            <!-- 뒤로가기 버튼 -->
            <form action="student-list.jsp" method="get">
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
