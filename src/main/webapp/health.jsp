<%@ page import="java.sql.*"%>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://wrongdatabase-1.cxso2woowtsy.ap-south-1.rds.amazonaws.com:3306/test",
            "admin", "admin123456");
        con.close();
        response.setStatus(200);
        out.println("OK");
    } catch (Exception e) {
        response.setStatus(500);
        out.println("DB connection failed: " + e.getMessage());
    }
%>
