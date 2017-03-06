package processing.test.orbitsimulator;
import android.app.Activity;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.view.ViewGroup.LayoutParams;
import android.app.FragmentTransaction;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import java.util.ArrayList;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.Manifest;
import processing.core.PApplet;
public class MainActivity extends Activity {
    PApplet fragment;
    private static final String MAIN_FRAGMENT_TAG = "main_fragment";
    private static final int REQUEST_PERMISSIONS = 1;
    int viewId = 0x1000;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Window window = getWindow();
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        window.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN, WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN);
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        FrameLayout frame = new FrameLayout(this);
        frame.setId(viewId);
        setContentView(frame, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        if (savedInstanceState == null) {
            fragment = new OrbitSimulator();
            FragmentTransaction ft = getFragmentManager().beginTransaction();
            ft.add(frame.getId(), fragment, MAIN_FRAGMENT_TAG).commit();
        } else {
            fragment = (PApplet) getFragmentManager().findFragmentByTag(MAIN_FRAGMENT_TAG);
        }
    }
    @Override
    public void onBackPressed() {
        fragment.onBackPressed();
        super.onBackPressed();
    }
    @Override
    public void onStart() {
        super.onStart();
        ArrayList<String> needed = new ArrayList<String>();
        int check;
        boolean danger = false;
        if (!needed.isEmpty()) {
          ActivityCompat.requestPermissions(this, needed.toArray(new String[needed.size()]), REQUEST_PERMISSIONS);
        } else if (danger) {
          fragment.onPermissionsGranted();
        }
    }
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
      if (requestCode == REQUEST_PERMISSIONS) {
        if (grantResults.length > 0) {
          for (int i = 0; i < grantResults.length; i++) {
            if (grantResults[i] != PackageManager.PERMISSION_GRANTED) {
              AlertDialog.Builder builder = new AlertDialog.Builder(this);
              builder.setMessage("Some permissions needed by the app were not granted, so it might not work as intended.")
                     .setCancelable(false)
                     .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                          public void onClick(DialogInterface dialog, int id) {
                          }
                     });
              AlertDialog alert = builder.create();
              alert.show();
            }
          }
          fragment.onPermissionsGranted();
        }
      }
    }
}
