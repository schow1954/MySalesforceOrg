public with sharing class Emailvalidationclass {

    public static Boolean validateEmail(String Email) {
        String email = (Email == null) ? null : Email.trim();
        if (String.isBlank(email)) {
            return false;
        }

        Pattern emailPattern = Pattern.compile('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$');
        Matcher matcher = emailPattern.matcher(email);
        return matcher.matches();
    }
}

