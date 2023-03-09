public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();

         // List info for a student.
          prettyPrint(c.getInfo("2222222222"));
          //pause();

          // Register a student for an unrestricted course, and check that he/she ends up registered (print info again).
          System.out.println(c.register("2222222222", "CCC111"));
          prettyPrint(c.getInfo("2222222222"));
          //pause();

          // Register the same student for the same course again, and check that you get an error response.
          System.out.println(c.register("2222222222", "CCC111"));
          prettyPrint(c.getInfo("2222222222"));
          //pause();


          //TODO
          // Unregister the student from the course, and then unregister him/her again from the same course.
          // Check that the student is no longer registered and that the second unregistration gives an error response.
          System.out.println(c.unregister("2222222222", "CCC111"));
          prettyPrint(c.getInfo("2222222222"));
          System.out.println(c.unregister("2222222222", "CCC111"));
          pause();









      
      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.5.1.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
   
   
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}
