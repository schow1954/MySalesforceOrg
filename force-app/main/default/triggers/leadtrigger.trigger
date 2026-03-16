trigger leadtrigger on Lead (before update) {
    
    for(lead ld : trigger.new){
        ld.Industry = 'Banking';
    }
}