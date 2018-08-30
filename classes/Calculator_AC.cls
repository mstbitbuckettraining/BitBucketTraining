public class Calculator_AC {   
    public static Double result = 0;
    
    public void find(String func, Double val1, Double val2) {
        
        if(func == 'add') {
            result = val1 + val2;
        }
		
		if(func == 'div') {
            result = val1 / val2;
        }
        
        System.debug('Result: ' + result);
        
    }
    
}