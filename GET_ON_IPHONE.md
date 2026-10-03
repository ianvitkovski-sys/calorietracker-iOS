# CalorieTracker — Getting It Onto Your iPhone

You are on **Windows with no Mac**. Apple requires that all iOS apps be compiled on macOS, so we use
**GitHub Actions** (GitHub's free macOS build machines) to compile the app, then install it on your iPhone
with **Sideloadly**, which signs it using your free Apple ID.

No paid Apple Developer account is required. The trade-off: the signature expires after **7 days**, so
you re-install once a week. That is a limit Apple imposes on free accounts, not something we can engineer
around.

---

## One-time setup

1. **Create a private GitHub repository** named `CalorieTracker`.
2. Upload the contents of this `CalorieTracker` folder to the repository root, so that `project.yml`
   sits at the top level next to `.github/`.
   The structure must be:

   ```
   CalorieTracker/            <- repository root
   |-- .github/workflows/build.yml
   |-- project.yml
   |-- CalorieTracker/
   |   |-- CalorieTrackerApp.swift
   |   |-- Info.plist
   |   |-- Assets.xcassets/
   |   |-- Config/
   |   |-- Models/  Views/  ViewModels/  Services/  Data/  Utils/
   ```

   From PowerShell in this folder:

   ```powershell
   git init
   git add .
   git commit -m "CalorieTracker iOS app"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/CalorieTracker.git
   git push -u origin main
   ```

   Keep the repository **private** if you prefer.

3. **Download Sideloadly** from <https://sideloadly.io/> and extract it on Windows.

---

## Building (repeat after every code change)

1. Open the **Actions** tab of your repository.
2. Click **Build iOS App** on the left.
3. Click **Run workflow** → confirm the branch is `main` → click the green **Run workflow**.
4. Wait roughly 5-10 minutes. A red X means the build failed — download the
   `CalorieTracker-build-log` artifact to see the compiler errors.
5. When it turns green, scroll to the bottom of the run page → **Artifacts** →
   download `CalorieTracker-unsigned-ipa`. GitHub unpacks it into a ZIP containing
   `CalorieTracker-unsigned.ipa`.

---

## Installing on your iPhone

1. Connect the iPhone to this PC with a USB cable, and tap **Trust** on the phone.
2. Open Sideloadly.
3. Drag `CalorieTracker-unsigned.ipa` onto the Sideloadly window.
   - Apple ID: the email address of your Apple account.
   - Password: your Apple account password. Sideloadly sends this only to Apple's own servers over
     HTTPS on your machine. If you are uneasy, create a separate throwaway Apple ID for this.
   - **Do not** enable "Request Update From iCloud" on a personal account.
4. Click **Start**. Sideloadly asks for an app-specific password if you use two-factor authentication:
   generate one at <https://appleid.apple.com> → *Sign-In and Security* → *App-specific passwords*.
5. Sideloadly installs the app. On the iPhone, go to **Settings → General → VPN & Device Management**,
   tap your Apple ID under *Developer App*, then **Trust**.
6. Open CalorieTracker from your home screen.

---

## Keeping it alive

The signature lasts 7 days. When the app stops launching, repeat the **Installing** steps above.
Sideloadly overwrites the previous copy; your logged meals are stored in SwiftData on the device and
survive a reinstall only if you do not delete the app. If you do delete it, the data goes with it.

Free accounts are limited to 3 apps with 10 app IDs total, which this project stays well within.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Build fails immediately | Code does not compile | Download `CalorieTracker-build-log`, search for `error:` |
| Xcode not found in log | Runner image moved | Update `macos-15` / the Xcode path in `.github/workflows/build.yml` |
| IPA artifact missing | Build step failed silently | Check the run summary; the log artifact has details |
| Sideloadly: "device not found" | USB trust not granted | Unplug, replug, accept **Trust**, unlock the phone |
| Sideloadly: wrong password | Two-factor auth on | Use an app-specific password |
| App won't open, then vanishes | 7-day signature expired | Reinstall via Sideloadly |
| "Untrusted Developer" | Profile not trusted | Settings → General → VPN & Device Management → Trust |
| Camera opens then closes | Permission denied | Settings → Privacy → Camera → CalorieTracker |

---

## Useful notes

- The build runs in **Release** configuration. Change `Release` to `Debug` in `build.yml` if you need
  the mock food-detection mode, since the real CoreML model is not bundled yet.
- A real `FoodDetector.mlmodel` is not present, so `FoodDetectionService` returns mock detections in
  `DEBUG` and falls back to heuristic portion estimates in `Release`.
- Supply a USDA FoodData Central API key by setting the `USDA_API_KEY` variable in `project.yml` or
  via repository secrets, then rebuilding.