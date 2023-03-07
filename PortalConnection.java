import org.json.JSONObject;

import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "portal";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }

    private void executeSql(String sql) throws SQLException {
        conn.prepareStatement(sql).execute();
    }

    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
        try {
            executeSql("INSERT INTO Registrations VALUES('" + student + "','" + courseCode + "');");
        }catch(SQLException e){
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
        return "{\"success\":true}";
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        try {
            executeSql("DELETE FROM Registrations" +
                    "WHERE student = '" + student + "' and course = '" + courseCode + "';");
        }catch(SQLException e){
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";

        }
      return "{\"success\":true}";
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{

        JSONObject obj = new JSONObject();

        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "SELECT * FROM BasicInformation JOIN PathToGraduation on idnr=student WHERE idnr=?;"
            )){
            
            st.setString(1, student);
            
            ResultSet rs = st.executeQuery();
            
            if(rs.next()){
                obj.put("student",rs.getString(1));
                obj.put("name",rs.getString(3));
                obj.put("login", rs.getString(2));
                obj.put("program",rs.getString(4));
            }
        }
        return obj.toString();
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}