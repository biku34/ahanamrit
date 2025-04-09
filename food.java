	package practice;
	
	import java.io.IOException;
	import java.io.PrintWriter;
	import java.sql.*;
	import jakarta.servlet.ServletException;
	import jakarta.servlet.annotation.WebServlet;
	import jakarta.servlet.http.HttpServlet;
	import jakarta.servlet.http.HttpServletRequest;
	import jakarta.servlet.http.HttpServletResponse;
	
	@WebServlet("/food")
	public class food extends HttpServlet {
	    private static final long serialVersionUID = 1L;
	
	    public food() {
	        super();
	    }
	
	    @Override
	    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	        // Get parameters from JS fetch
	        String ingredient = request.getParameter("ingredient");
	        String effect = request.getParameter("effect");
	
	        response.setContentType("text/plain");
	        PrintWriter out = response.getWriter();
	
	        
	        // DB Connection Details
	        String jdbcURL = "jdbc:mysql://localhost:3306/foodlabel";
	        String dbUser = "root"; // change this if needed
	        String dbPassword = ""; // change this if needed
	
	        try {
	            Class.forName("com.mysql.cj.jdbc.Driver");
	            Connection conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
	
	            String sql = "INSERT INTO scanned_labels (ingredient, health_effect) VALUES (?, ?)";
	            PreparedStatement stmt = conn.prepareStatement(sql);
	            stmt.setString(1, ingredient);
	            stmt.setString(2, effect);
	
	            int rowsInserted = stmt.executeUpdate();
	            if (rowsInserted > 0) {
	                out.print("✅ Data saved successfully!");
	            } else {
	                out.print("❌ Failed to save data.");
	            }
	
	            stmt.close();
	            conn.close();
	
	        } catch (Exception e) {
	            e.printStackTrace();
	            out.print("❌ Error: " + e.getMessage());
	        }
	    }
	}
