package firstProject;

public class MyApplication {

	public static void main(String[] args) {
		System.out.println("Hello World!");
		System.out.println("My Name is Dana");
		System.out.println(args);
		// Ausgabe der Kommandozeilenparameter
		for (int i=args.length-1; i>=0; i--)
			System.out.println(args[i]);

	}

}
