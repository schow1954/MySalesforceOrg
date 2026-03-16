public class TrailLoop {
   
    //Here is a combined problem of a query that needs a filter
    //and a loop that continually calls out to the database
    public static void AllGoodThings(Account a) {
        List<Task> tlist = new List<Task>();
        for (Task t : [Select Id, status, whatId From Task where whatId =:a.id]) {
            t.status = 'Completed';
            tlist.add(t);
        }
        update tlist;
    } 
}