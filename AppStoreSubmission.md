# App Store Connect — Submission Sheet

Everything here is ready to copy-paste. Items marked **YOU** need a decision or
asset only you can provide.

---

## App record

| Field | Value |
| --- | --- |
| Platform | iOS |
| Name | `Planet: Solar System` |
| Primary language | English (U.S.) |
| Bundle ID | `itkhld.dev.Planet` |
| SKU | `itkhld.dev.Planet` |
| User Access | Full Access |

> The SKU is internal-only and can never be changed. Reusing the bundle ID is
> the common convention.

---

## Version information

**Version:** `1.0`  **Build:** `1`

### Subtitle (30 char max)

```
Explore the solar system in 3D
```

### Promotional text (170 char max — editable without a new build)

```
Tap any planet to explore it in 3D, test yourself with 135 questions, and find out what you'd weigh on Jupiter. Learning about space, made to be played with.
```

### Description

```
Planet turns the solar system into something you can hold, spin, and poke at.

Built for curious minds of all ages, it trades walls of text for things you can actually touch: drag through the orbits, tap a world to open it up, and see the real numbers behind it.

EXPLORE THE SOLAR SYSTEM
Pinch to zoom and drag to pan across the planets in their orbits. Tap any planet — or the Sun — to open its details: diameter, distance from the Sun, day length, and a short description. Then open it as an interactive 3D model you can turn in your hands.

BROWSE AND SEARCH
Every planet, the Sun, 20 notable moons, and a full overview of the solar system itself — how it formed, what's in it, and where we sit in the Milky Way. Search across all of it: type "Olympus" and you'll land on Mars.

MOONS
Titan's lakes of liquid methane. Enceladus firing geysers of water into space. Io, the most volcanic world we know. Ganymede, bigger than Mercury. Triton, orbiting backwards because Neptune caught it.

COMPARE
Put two worlds side by side and watch the scale land. Diameter, distance, day length, year length, gravity, and moons — with the planets drawn to their true relative size. Line Earth up against the Sun and see what 109 times wider actually looks like.

TEST YOURSELF
135 questions, ten per round, drawn fresh every time. Every answer comes with a one-line explanation of why it's right, so a wrong guess teaches you something. Miss a few and you'll get them back at the end, with the reasons, to review.

WEIGH IN, ANYWHERE
Enter your weight and see what you'd weigh on every other planet — in kilograms or pounds. Enter your age and find out how many laps of the Sun you'd have made on Mars, or Neptune.

SEE THEM IN 3D
Load a detailed 3D model of any planet, spin it, and get close.

No accounts. No ads. No data collected. Just the solar system.
```

### Keywords (100 char max, comma-separated, no spaces)

```
solar,system,planets,space,astronomy,science,kids,education,3d,quiz,learn,moons,stars,universe
```

### Support URL — **YOU**

Required. Must be a real, reachable page. A single GitHub Pages page or a Gist
with your contact email is enough.

### Marketing URL — optional, leave blank

### Copyright — **YOU**

Format: `2026 <name or entity>`. This is a legal field, so it's yours to fill.

### Version release

Recommended: **Automatically release this version** after approval.

---

## App Review Information

### Sign-in required?

**No** — there are no accounts.

### Notes for the reviewer

```
No account or sign-in is required. All content is bundled; the app makes no network requests.

The "Explore in 3D" and Simulation features render bundled .usdz models and work on any device, including the simulator.

The AR view requests camera access to place a planet model in your surroundings. This requires a physical device with ARKit support — on the simulator the AR screen will show an alert instead, which is expected.

The app collects no data of any kind.
```

### Contact information — **YOU**

Name, phone, email.

### Attachment

None needed.

---

## App Privacy

Answer: **Data is not collected**.

The app has no analytics, no third-party SDKs, no network calls, and no
account system. Everything stored (`weightOnEarth`, `ageOnEarth`, `HighScore`,
unit and haptics preferences, and whether the intro has been seen) lives in
`UserDefaults` on the device and never leaves it.

---

## Age Rating

Every content question answers **None**. Expected result: **4+**.

- No violence, profanity, sexual content, gambling, drugs, or horror themes
- No user-generated content, no chat, no ads
- No unrestricted web access — the app opens no links at all
- Data collection: none

### Category

- **Primary:** Education (already set in the project as
  `public.app-category.education`)
- **Secondary:** suggest Reference

> **Decision — YOU:** The onboarding describes the app as "designed especially
> for children." If you opt into the **Kids** category, Apple applies extra
> rules: a privacy policy becomes mandatory, third-party analytics/ads are
> banned, and outbound links need a parental gate. This app would likely pass
> all of them today — it has no analytics, ads, or links — but it invites
> stricter review and locks in obligations for every future update. Education
> avoids all of that and is the safer default. It's a real choice, not a
> formality.

---

## Screenshots — **YOU**

Apple requires only the largest size per device family and scales down.

| Device family | Size | Required |
| --- | --- | --- |
| iPhone 6.9" | 1320 × 2868 or 1290 × 2796 | Yes |
| iPad 13" | 2064 × 2752 or 2048 × 2732 | Yes — the target is iPhone + iPad |

Minimum 3, maximum 10 per family. Suggested set, in order:

1. Solar System map with the orbits
2. A planet detail view (Saturn or Jupiter reads best)
3. Compare — Earth vs the Sun, showing the scale
4. Quiz mid-question with an explanation revealed
5. Weight calculator with results
6. Moons list

> **iPad is not optional.** `TARGETED_DEVICE_FAMILY = "1,2"` means you ship both,
> so iPad screenshots are required. If you'd rather skip producing and
> maintaining them, set the target to `1` (iPhone only) and the requirement
> disappears.

App Preview videos are optional — skip for 1.0.

---

## Already handled in the project

- `IPHONEOS_DEPLOYMENT_TARGET` lowered from **26.0 → 17.0**. At 26.0 the App
  Store would have offered the app to almost no one, possibly not even the
  reviewer's device. Nothing in the code needs 26.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` added, so App Store Connect
  stops asking the export-compliance question on every upload. Correct here: the
  app uses no encryption beyond the OS defaults.
- `INFOPLIST_KEY_NSCameraUsageDescription` is set (required for ARKit — a missing
  one is the classic AR rejection).
- `INFOPLIST_KEY_LSApplicationCategoryType` is Education.
- Version `1.0`, build `1`.

---

## Worth a look before you ship

- **Landscape.** `UISupportedInterfaceOrientations` currently allows landscape on
  both iPhone and iPad, but the layouts were designed portrait-first. Reviewers
  do rotate the device. Either check every screen in landscape, or restrict
  iPhone to portrait.
- **Test the AR path on a real device.** It's the one feature that can't be
  verified in the simulator, and reviewers test on hardware.
- **Archive with the Release configuration** and validate in Xcode's Organizer
  before uploading — validation catches icon and entitlement problems early.
