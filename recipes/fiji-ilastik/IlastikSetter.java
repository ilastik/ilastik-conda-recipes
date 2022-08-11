import java.util.prefs.Preferences;

public class IlastikSetter {
	public static void main(String... args) {
		Preferences prefs = Preferences.userRoot().node("org/ilastik/ilastik4ij/ui/IlastikOptions");
		prefs.put("executableFile", args[0]);
	}
}
