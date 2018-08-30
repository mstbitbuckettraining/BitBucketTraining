public class Calculator_AC {   
    public static Double result = 0;
    
    public void find(String func, Double val1, Double val2) {
        
        if(func == 'Sub') {
            result = val1 + val2;
        }
		if(func == 'Add') {
            result = val1 + val2;
        }
		if(func == 'Div') {
            result = val1 / val2;
        }
		if(func == 'Mul') {
            result = val1 * val2;
        }
        
        System.debug('Result: ' + result);
        
    }
    
}