import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn

def set_cell_background(cell, color_hex):
    shading_elm = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{color_hex}"/>')
    cell._tc.get_or_add_tcPr().append(shading_elm)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('w:top', top), ('w:bottom', bottom), ('w:left', left), ('w:right', right)]:
        node = OxmlElement(m)
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def create_manual_docx():
    doc = Document()

    # Configure Margins (1 inch all around)
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)

    # Set Base Style Font to Times New Roman
    style = doc.styles['Normal']
    font = style.font
    font.name = 'Times New Roman'
    font.size = Pt(12)
    font.color.rgb = RGBColor(30, 41, 59) # Slate 800

    def add_title(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(4)
        run = p.add_run(text)
        run.font.name = 'Times New Roman'
        run.font.size = Pt(24)
        run.font.bold = True
        run.font.color.rgb = RGBColor(15, 23, 42)

    def add_subtitle(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(24)
        run = p.add_run(text)
        run.font.name = 'Times New Roman'
        run.font.size = Pt(13)
        run.font.italic = True
        run.font.color.rgb = RGBColor(71, 85, 105)

    def add_heading1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(18)
        p.paragraph_format.space_after = Pt(8)
        run = p.add_run(text)
        run.font.name = 'Times New Roman'
        run.font.size = Pt(16)
        run.font.bold = True
        run.font.color.rgb = RGBColor(194, 65, 12) # Terracotta / Brand Orange

    def add_heading2(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(6)
        run = p.add_run(text)
        run.font.name = 'Times New Roman'
        run.font.size = Pt(13.5)
        run.font.bold = True
        run.font.color.rgb = RGBColor(30, 41, 59)

    def add_heading3(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(10)
        p.paragraph_format.space_after = Pt(4)
        run = p.add_run(text)
        run.font.name = 'Times New Roman'
        run.font.size = Pt(12)
        run.font.bold = True
        run.font.italic = True
        run.font.color.rgb = RGBColor(51, 65, 85)

    def add_paragraph(text, bold_prefix=None):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_bold = p.add_run(bold_prefix)
            r_bold.font.name = 'Times New Roman'
            r_bold.font.size = Pt(12)
            r_bold.font.bold = True
        r = p.add_run(text)
        r.font.name = 'Times New Roman'
        r.font.size = Pt(12)
        return p

    def add_bullet(text, bold_prefix=None):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_bold = p.add_run(bold_prefix)
            r_bold.font.name = 'Times New Roman'
            r_bold.font.size = Pt(12)
            r_bold.font.bold = True
        r = p.add_run(text)
        r.font.name = 'Times New Roman'
        r.font.size = Pt(12)

    def add_callout(text, title="NOTE"):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = tbl.cell(0, 0)
        set_cell_background(cell, "F8FAFC")
        set_cell_margins(cell, top=140, bottom=140, left=200, right=200)
        
        tcPr = cell._tc.get_or_add_tcPr()
        borders = parse_xml(f'<w:tcBorders {nsdecls("w")}><w:left w:val="single" w:sz="24" w:space="0" w:color="EA580C"/><w:top w:val="none"/><w:right w:val="none"/><w:bottom w:val="none"/></w:tcBorders>')
        tcPr.append(borders)

        cp = cell.paragraphs[0]
        cp.paragraph_format.space_before = Pt(0)
        cp.paragraph_format.space_after = Pt(0)
        tr = cp.add_run(f"[{title}] ")
        tr.font.name = 'Times New Roman'
        tr.font.size = Pt(11)
        tr.font.bold = True
        tr.font.color.rgb = RGBColor(234, 88, 12)
        
        cr = cp.add_run(text)
        cr.font.name = 'Times New Roman'
        cr.font.size = Pt(11)
        cr.font.color.rgb = RGBColor(51, 65, 85)
        
        p_sp = doc.add_paragraph()
        p_sp.paragraph_format.space_before = Pt(4)
        p_sp.paragraph_format.space_after = Pt(4)

    # -------------------------------------------------------------
    # DOCUMENT CONTENT
    # -------------------------------------------------------------
    add_title("DAILY TASKS & REWARDS PLATFORM")
    add_subtitle("Comprehensive System Manual: User App, Web Admin Console, SQL Database Architecture & Mobile Sideloading Guide (.APK / .IPA / Sideloadly)")

    # 1. Executive Summary
    add_heading1("1. Executive Summary & Overview")
    add_paragraph("The Daily Tasks & Rewards Platform is a high-performance, community-engagement application inspired by the modern discovery aesthetics of the EatClub mobile interface. Instead of restaurant promotions and discounts, the platform empowers administrators to orchestrate, schedule, and verify real-world citizen activities, emergency preparedness drills, environmental sustainability challenges, fitness goals, and community volunteer tasks.")
    add_paragraph("Users explore attractive deal-style task cards featuring hero imagery, dynamic point bounties, category badges, and live countdown timers. Users submit verifiable proof (including text narratives, camera photos, video recordings, file attachments, and GPS geographic coordinates). Once submitted, tasks undergo verification via an enterprise Web-Based Admin Console. Approvals trigger atomic points awards directly into the user's digital wallet, which can be redeemed for real-world rewards and merchant vouchers.")

    # 2. Database & Backend Architecture
    add_heading1("2. Relational SQL Database Architecture (Zero Firebase)")
    add_paragraph("The entire platform operates strictly on a normalized, ACID-compliant Relational SQL Database architecture. All legacy cloud dependencies (Firebase Authentication, Cloud Firestore, Firebase Storage, and Firebase Cloud Messaging) have been completely removed, eliminating third-party cloud subscription fees, vendor lock-in, and privacy constraints.")
    
    add_heading2("2.1 SQL Schema Architecture")
    add_paragraph("The relational database schema is structured into 6 primary relational tables with foreign keys and index optimization:")
    add_bullet(" Stores registered users, credential hashes (SHA-256), contact numbers, role-based access levels ('user' or 'admin'), and live wallet balances.", "users: ")
    add_bullet(" Stores daily activities, category taxonomies, points bounties, countdown deadlines, step-by-step instructions, and required evidence types as structured JSON arrays.", "tasks: ")
    add_bullet(" Tracks citizen evidence submissions, review lifecycle states ('pending', 'approved', 'rejected'), reviewer identity, rejection feedback reasons, and location coordinates.", "submissions: ")
    add_bullet(" Manages redeemable partner vouchers, stock availability counters, and point costs.", "rewards: ")
    add_bullet(" Records fulfilled voucher transactions, generating unique redemption reference IDs.", "redemptions: ")
    add_bullet(" An immutable audit ledger tracking all point earnings and redemption expenditures with timestamps.", "point_transactions: ")

    add_heading2("2.2 Zero-Dependency SQL Backend Server")
    add_paragraph("The central server (backend_sql/server.js) utilizes Node.js's native node:sqlite engine. It initializes the database schema, seeds default challenges, serves high-performance REST API endpoints, processes multi-modal file uploads, and statically serves the Web Admin Dashboard on port 5000 with zero external npm installations required.")

    # 3. User Mobile Application Functionalities
    add_heading1("3. Mobile User Experience & Functionality (Android & iOS)")
    add_paragraph("The mobile application is crafted using Flutter with GetX reactive state management. The user interface embodies the EatClub visual language with terracotta gradients, rounded card elevations, and tactile feedback.")

    add_heading2("3.1 Authentication & Security")
    add_bullet("Citizens register using their Full Name, Email Address, Mobile Phone Number, and Password. Dual-role support allows toggling between standard user and administrator modes for comprehensive testing.", "Registration & Sign-In: ")
    add_bullet("One-tap demo sign-in allows immediate entry as either 'Citizen Jordan Lee' or 'System Administrator'.", "Demo Mode: ")

    add_heading2("3.2 EatClub-Inspired Explore Feed")
    add_bullet("Displays today's active tasks with vibrant hero banners, dynamic point pills (+250 PTS), and real-time countdown badges (e.g., '14h 22m left').", "Deal-Style Cards: ")
    add_bullet("Horizontal chip selector allows instant filtering across Eco & Green, Fitness & Health, Community, Safety & Preparedness, and Education.", "Category Filters: ")
    add_bullet("Users can search tasks by title or sort by 'Featured', 'Highest Points', or 'Ending Soon'.", "Search & Sorting: ")

    add_heading2("3.3 Task Details & Multi-Modal Proof Submission")
    add_paragraph("Opening any task reveals detailed guidelines, requirements checklist, and the dynamic evidence capture module:")
    add_bullet("Field for written explanations or route notes.", "1. Text Proof: ")
    add_bullet("Native camera capture and photo gallery picker with multi-image preview.", "2. Photo Evidence: ")
    add_bullet("Video recording capability to document interactive activities.", "3. Video Proof: ")
    add_bullet("System file picker for PDF documents, digital receipts, or test reports.", "4. File Attachments: ")
    add_bullet("One-tap hardware GPS coordinate acquisition with reverse geocoding into physical street addresses.", "5. GPS Verification: ")

    add_heading2("3.4 'My Tasks' Lifecycle Manager")
    add_paragraph("Organized into 4 distinct tabs to eliminate ambiguity regarding submission status:")
    add_bullet("Shows tasks the user has started but not yet submitted.", "Active: ")
    add_bullet("Submissions awaiting administrator verification, displaying exact submission time.", "Pending Review: ")
    add_bullet("Approved tasks displaying the points credited to the user's wallet.", "Completed: ")
    add_bullet("Rejected submissions highlighting an alert banner with the specific reason and feedback provided by the administrator.", "Rejected: ")

    add_heading2("3.5 Rewards Store & Digital Wallet")
    add_paragraph("Users monitor their current points balance via a premium gradient wallet card. Points can be redeemed for gift cards, coffee vouchers, and fitness passes with real-time balance deductions and transaction ledger logging.")

    # 4. Web-Based Administrator Console
    add_heading1("4. Web-Based Enterprise Admin Console")
    add_paragraph("Accessible via any desktop browser at http://localhost:5000, the Web Admin Dashboard allows administrators to control operations without modifying source code.")

    add_heading2("4.1 Executive Dashboard")
    add_paragraph("Presents four live KPI metric counters: Active Tasks in circulation, Pending Submissions awaiting review, Completed Tasks, and Total Points Awarded across the community. The dashboard also features an urgent review queue table.")

    add_heading2("4.2 Task Studio (Create, Edit, Schedule & Delete)")
    add_paragraph("A full-featured authoring suite enabling administrators to publish new tasks with custom hero banner URLs, category assignments, point values, deadline durations, instructions, and required evidence checkboxes (Text, Photo, Video, File, Location).")

    add_heading2("4.3 Evidence Inspection Modal & Atomic Approvals")
    add_paragraph("Clicking 'Inspect Evidence' on any pending submission opens a modal presenting the citizen's responses, high-resolution photos, and GPS map address. The administrator can:")
    add_bullet("Executes an atomic SQL transaction that transitions the submission to 'approved', credits points to the user's account, and creates an audit record.", "Approve Submission: ")
    add_bullet("Prompts the administrator to input explicit rejection feedback (e.g., 'Photo too blurry' or 'Location out of bounds'), which appears immediately on the citizen's mobile screen.", "Reject with Reason: ")

    add_heading2("4.4 Rewards & User Directory")
    add_paragraph("Allows adding new voucher inventory, setting stock levels, inspecting all registered users, and manually granting discretionary bonus points.")

    # 5. Mobile Deployment & Sideloading Manual
    add_heading1("5. Mobile Deployment & Sideloading Manual (.APK & .IPA)")
    add_paragraph("This section provides step-by-step instructions for compiling and installing the application on physical Android and iOS devices without publishing to Google Play or Apple App Store.")

    add_heading2("5.1 Android Installation (.APK)")
    add_paragraph("Android provides native sideloading support for .apk files without requiring developer accounts.")
    add_heading3("Step 1: Compile the Release APK")
    add_paragraph("Open PowerShell in the project directory and run:", bold_prefix="Command: ")
    add_paragraph("flutter build apk --release")
    add_paragraph("The output binary is located at: build/app/outputs/flutter-apk/app-release.apk")
    
    add_heading3("Step 2: Transfer and Install on Android Device")
    add_bullet("Connect your Android phone to your PC via USB cable and copy 'app-release.apk' to the 'Downloads' folder (or email/upload to Google Drive).", "Method A (Direct Transfer): ")
    add_bullet("Open the 'Files' app on your Android phone, tap 'app-release.apk', and tap 'Install'. If prompted with 'Install Unknown Apps', toggle 'Allow from this source'.", "Security Prompt: ")
    add_bullet("With Developer Options enabled on Android, run: adb install -r build/app/outputs/flutter-apk/app-release.apk", "Method B (ADB Command Line): ")

    add_heading2("5.2 iOS Installation (.IPA) & Sideloadly Complete Guide")
    add_paragraph("Apple enforces strict code signing on iOS. To install an .ipa package on an iPhone or iPad without an Apple Developer subscription ($99/year), you can use Sideloadly.")

    add_heading3("What is Sideloadly?")
    add_paragraph("Sideloadly is a free, popular desktop tool for Windows and macOS that allows you to sign and sideload any iOS .ipa package directly onto your iPhone or iPad using your personal, free Apple ID.")

    add_heading3("Prerequisites for Windows Users")
    add_bullet("Install iTunes for Windows directly from Apple (DO NOT use the Microsoft Store version): https://www.apple.com/itunes/", "1. Apple iTunes: ")
    add_bullet("Install iCloud for Windows from Apple's direct installer (non-Microsoft Store version).", "2. Apple iCloud: ")
    add_bullet("Download and install Sideloadly from the official website: https://sideloadly.io/", "3. Sideloadly Software: ")

    add_heading3("Step-by-Step Sideloadly Installation Tutorial")
    add_bullet("Generate the unsigned iOS archive by running: flutter build ipa --no-codesign", "Step 1 (Generate .ipa): ")
    add_bullet("Connect your iPhone or iPad to your Windows PC using an authentic Lightning or USB-C cable. If your device displays 'Trust This Computer?', tap 'Trust' and enter your device passcode.", "Step 2 (Connect Device): ")
    add_bullet("Launch Sideloadly on your PC. Your connected iPhone should appear in the 'Device' dropdown.", "Step 3 (Open Sideloadly): ")
    add_bullet("Drag and drop your .ipa file into the large IPA icon on the left side of Sideloadly.", "Step 4 (Select IPA): ")
    add_bullet("In the 'Apple ID' field, enter your personal Apple ID email address (used only for generating the local signature certificate).", "Step 5 (Enter Apple ID): ")
    add_bullet("Click the 'Start' button. When prompted, enter your Apple ID password (and 2-Factor Authentication verification code sent to your iPhone). Sideloadly will automatically sign the application, bundle provisioning profiles, and install it on your device.", "Step 6 (Begin Signing): ")

    add_heading3("Step-by-Step Device Authorization on iPhone")
    add_paragraph("After Sideloadly finishes installing the app, tapping the icon on your home screen will show an 'Untrusted Developer' dialog. Follow these steps to authorize the app:")
    add_bullet("Open Settings -> General -> VPN & Device Management.", "1. Trust Developer Profile: ")
    add_bullet("Under 'Developer App', tap your Apple ID email address.", "2. Select Certificate: ")
    add_bullet("Tap 'Trust [Your Apple ID]', and confirm by tapping 'Trust'.", "3. Confirm Trust: ")
    add_bullet("On iOS 16, 17, and 18, Apple requires Developer Mode to run sideloaded apps: Go to Settings -> Privacy & Security -> Scroll down to 'Developer Mode' -> Toggle ON -> Tap 'Restart'. Upon reboot, tap 'Turn On' and enter your device passcode.", "4. Enable Developer Mode (iOS 16+): ")

    add_callout(
        "Free Apple IDs permit up to 3 sideloaded apps per device with certificates valid for 7 days. Sideloadly includes an automatic background Wi-Fi refresh feature: as long as your iPhone and PC are connected to the same Wi-Fi network, Sideloadly will wirelessly resign the app every week without requiring a cable reconnection.",
        title="SIDELOADLY 7-DAY RE-SIGNING NOTE"
    )

    # 6. Step-by-Step Testing & Verification Commands
    add_heading1("6. System Verification & Quick Start Commands")
    add_paragraph("To run and test the complete system locally, execute the following commands:")

    add_heading2("6.1 Launch Central SQL Database Server & Admin Console")
    add_paragraph("node backend_sql/server.js", bold_prefix="Terminal 1: ")
    add_paragraph("This command initializes SQLite database at backend_sql/tasks_app.sqlite, applies migrations, seeds challenges, and serves the Web Admin Dashboard at http://localhost:5000.")

    add_heading2("6.2 Launch Mobile Application")
    add_paragraph("flutter run", bold_prefix="Terminal 2: ")
    add_paragraph("Select your connected Android device, iOS simulator, or Chrome to launch the EatClub-style daily tasks mobile client.")

    add_heading2("6.3 Execute Static Code Analysis")
    add_paragraph("dart analyze lib/main.dart lib/core lib/models lib/services lib/controllers lib/views", bold_prefix="Analysis Command: ")
    add_paragraph("Output: No issues found! (0 errors, 0 warnings).")

    # Save document
    output_filename = "Daily_Tasks_Platform_Complete_Manual.docx"
    output_path = os.path.join(r"c:\Users\HP\Desktop\Emergency App", output_filename)
    doc.save(output_path)
    print(f"Document successfully created at: {output_path}")

if __name__ == '__main__':
    create_manual_docx()
