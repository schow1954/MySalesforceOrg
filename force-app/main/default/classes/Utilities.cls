public with sharing class Utilities {
   
    //get picklist label base on object and field name.
    public static String[] picklist_values(String object_name, String field_name){
      String[] values = new String[]{};
      String[] types = new String[]{object_name};
      Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
      for(Schema.DescribeSobjectResult res : results) {
         for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()){
            if (entry.isActive()) {values.add(entry.getValue());}
         }
      }
      return values;
   }
}