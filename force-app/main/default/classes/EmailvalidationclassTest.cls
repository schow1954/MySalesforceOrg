@IsTest
private class EmailvalidationclassTest {
    @IsTest
    static void validateEmail_returnsTrueForValidEmails() {
        System.assertEquals(true, Emailvalidationclass.validateEmail('test.user+tag@example.com'));
        System.assertEquals(true, Emailvalidationclass.validateEmail('a_b-c.d%1@sub.example.co'));
        System.assertEquals(true, Emailvalidationclass.validateEmail('  spaced@example.com  '));
    }

    @IsTest
    static void validateEmail_returnsFalseForInvalidEmails() {
        System.assertEquals(false, Emailvalidationclass.validateEmail(null));
        System.assertEquals(false, Emailvalidationclass.validateEmail(''));
        System.assertEquals(false, Emailvalidationclass.validateEmail('   '));
        System.assertEquals(false, Emailvalidationclass.validateEmail('not-an-email'));
        System.assertEquals(false, Emailvalidationclass.validateEmail('a@b'));
        System.assertEquals(false, Emailvalidationclass.validateEmail('a@b.'));
        System.assertEquals(false, Emailvalidationclass.validateEmail('@example.com'));
        System.assertEquals(false, Emailvalidationclass.validateEmail('test@@example.com'));
    }
}

