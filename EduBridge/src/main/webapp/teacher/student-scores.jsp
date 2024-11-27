<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
        <div class="box">
            <!-- 성적 관리 관련 버튼 -->
            <div class="flex">
                <div class="flex-item">
                    <h2>출석 관리</h2>
                    <form action="student-attendance.jsp" method="get">
                        <input type="hidden" name="userId" value="<%= request.getParameter("userId") %>">
                        <input type="hidden" name="role" value="<%= request.getParameter("role") %>">
                        <button type="submit">이동</button>
                    </form>
                </div>
                <div class="flex-item">
                    <h2>과제 관리</h2>
                    <form action="student-homework.jsp" method="get">
                        <input type="hidden" name="userId" value="<%= request.getParameter("userId") %>">
                        <input type="hidden" name="role" value="<%= request.getParameter("role") %>">
                        <button type="submit">이동</button>
                    </form>
                </div>
                <div class="flex-item">
                    <h2>시험 관리</h2>
                    <form action="student-exam.jsp" method="get">
                        <input type="hidden" name="userId" value="<%= request.getParameter("userId") %>">
                        <input type="hidden" name="role" value="<%= request.getParameter("role") %>">
                        <button type="submit">이동</button>
                    </form>
                </div>
                <div class="flex-item">
                    <h2>종합 성적 관리</h2>
                    <form action="student-total-scores.jsp" method="get">
                        <input type="hidden" name="userId" value="<%= request.getParameter("userId") %>">
                        <input type="hidden" name="role" value="<%= request.getParameter("role") %>">
                        <button type="submit">이동</button>
                    </form>
                </div>
            </div>
        </div>
        <!-- 뒤로가기 및 로그아웃 버튼 -->
        <form action="dashboard.jsp" method="get" style="margin-top: 20px;">
            <input type="hidden" name="userId" value="<%= request.getParameter("userId") %>">
            <input type="hidden" name="role" value="<%= request.getParameter("role") %>">
            <button type="submit" class="back-button">뒤로가기</button>
        </form>
        <form action="../login.jsp" method="get" style="margin-top: 20px;">
            <button type="submit" class="logout-button">로그아웃</button>
        </form>
    </div>
</body>
</html>
