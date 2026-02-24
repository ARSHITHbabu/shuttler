"""
PDF Generator for PRODUCTION_READINESS_PLAN.md
Uses reportlab to produce a clean, professional PDF.
Run: python generate_pdf.py
"""

import re
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    HRFlowable, KeepTogether, PageBreak
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.platypus import ListFlowable, ListItem

# ── Colour Palette ────────────────────────────────────────────────────────────
DARK_BG      = colors.HexColor("#1C1C1E")
ACCENT_BLUE  = colors.HexColor("#0A84FF")
ACCENT_GREEN = colors.HexColor("#30D158")
ACCENT_RED   = colors.HexColor("#FF453A")
ACCENT_ORANGE= colors.HexColor("#FF9F0A")
LIGHT_GREY   = colors.HexColor("#F2F2F7")
MID_GREY     = colors.HexColor("#8E8E93")
DARK_TEXT    = colors.HexColor("#1C1C1E")
WHITE        = colors.white

# ── Styles ────────────────────────────────────────────────────────────────────
styles = getSampleStyleSheet()

def make_style(name, parent="Normal", **kwargs):
    s = ParagraphStyle(name=name, parent=styles[parent], **kwargs)
    return s

cover_title = make_style("CoverTitle",
    fontSize=28, fontName="Helvetica-Bold",
    textColor=DARK_TEXT, alignment=TA_CENTER, spaceAfter=8)

cover_sub = make_style("CoverSub",
    fontSize=13, fontName="Helvetica",
    textColor=MID_GREY, alignment=TA_CENTER, spaceAfter=4)

cover_meta = make_style("CoverMeta",
    fontSize=10, fontName="Helvetica",
    textColor=MID_GREY, alignment=TA_CENTER, spaceAfter=2)

h1 = make_style("H1",
    fontSize=18, fontName="Helvetica-Bold",
    textColor=ACCENT_BLUE, spaceBefore=18, spaceAfter=6,
    borderPad=4)

h2 = make_style("H2",
    fontSize=13, fontName="Helvetica-Bold",
    textColor=DARK_TEXT, spaceBefore=14, spaceAfter=4,
    leftIndent=0)

h3 = make_style("H3",
    fontSize=11, fontName="Helvetica-Bold",
    textColor=ACCENT_BLUE, spaceBefore=10, spaceAfter=3,
    leftIndent=8)

body = make_style("Body",
    fontSize=9.5, fontName="Helvetica",
    textColor=DARK_TEXT, spaceAfter=3, leading=14,
    leftIndent=8, alignment=TA_JUSTIFY)

bullet_style = make_style("Bullet",
    fontSize=9, fontName="Helvetica",
    textColor=DARK_TEXT, spaceAfter=2, leading=13,
    leftIndent=20, firstLineIndent=-10)

code_style = make_style("Code",
    fontSize=8, fontName="Courier",
    textColor=colors.HexColor("#1D3557"),
    backColor=colors.HexColor("#EEF2FF"),
    spaceAfter=4, leading=12,
    leftIndent=20, rightIndent=8,
    borderPad=4)

status_done   = make_style("StatusDone",   fontSize=9, fontName="Helvetica-Bold",
    textColor=ACCENT_GREEN, leftIndent=8, spaceAfter=2)
status_fail   = make_style("StatusFail",   fontSize=9, fontName="Helvetica-Bold",
    textColor=ACCENT_RED, leftIndent=8, spaceAfter=2)
status_warn   = make_style("StatusWarn",   fontSize=9, fontName="Helvetica-Bold",
    textColor=ACCENT_ORANGE, leftIndent=8, spaceAfter=2)

toc_style = make_style("TOC",
    fontSize=9.5, fontName="Helvetica",
    textColor=ACCENT_BLUE, spaceAfter=2, leading=14, leftIndent=12)

note_style = make_style("Note",
    fontSize=9, fontName="Helvetica-Oblique",
    textColor=colors.HexColor("#8B0000"),
    backColor=colors.HexColor("#FFF3F3"),
    leftIndent=12, rightIndent=8, spaceAfter=6, leading=13,
    borderPad=6)

# ── Helpers ───────────────────────────────────────────────────────────────────

def hr(color=ACCENT_BLUE, thickness=0.5):
    return HRFlowable(width="100%", thickness=thickness, color=color, spaceAfter=4, spaceBefore=4)

def status_para(text):
    t = text.strip()
    if t.startswith("✅") or "Completed" in t or "Fully Implemented" in t:
        return Paragraph(t, status_done)
    elif t.startswith("❌") or "Not Implemented" in t or "Not configured" in t:
        return Paragraph(t, status_fail)
    elif t.startswith("⚠️") or "Partially" in t:
        return Paragraph(t, status_warn)
    return Paragraph(t, body)

def clean(text):
    """Convert markdown inline formatting to ReportLab-safe XML."""
    # 1. Escape raw XML characters first (before we add our own tags)
    text = re.sub(r'&(?!amp;|lt;|gt;|quot;|#\d+;)', '&amp;', text)
    text = text.replace('<', '&lt;').replace('>', '&gt;')

    # 2. Extract inline code spans into placeholders FIRST (to avoid italic/bold
    #    regexes mangling backtick content like `*.pem`)
    placeholders = {}
    def stash_code(m):
        key = f"\x00CODE{len(placeholders)}\x00"
        inner = m.group(1)
        # The inner text is already XML-escaped from step 1; just display it
        placeholders[key] = f'<font name="Courier" size="8">{inner}</font>'
        return key
    text = re.sub(r'`([^`]+)`', stash_code, text)

    # 3. Bold (must come before italic so ** is consumed first)
    text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
    # 4. Italic — only replace if it doesn't start with a space after *
    text = re.sub(r'\*([^\s*][^*]*?)\*', r'<i>\1</i>', text)
    # 5. Restore code placeholders
    for key, val in placeholders.items():
        text = text.replace(key, val)
    return text

def is_table_row(line):
    return line.strip().startswith("|") and line.strip().endswith("|")

def parse_md_table(lines, start):
    """Parse a markdown table starting at lines[start], return (flowable, end_idx)."""
    rows = []
    i = start
    while i < len(lines) and is_table_row(lines[i]):
        raw = lines[i].strip().strip("|")
        cells = [c.strip() for c in raw.split("|")]
        rows.append(cells)
        i += 1
    if not rows:
        return None, start

    # Remove separator row (---|---)
    clean_rows = [r for r in rows if not all(re.match(r'^-+$', c.strip('-').strip()) for c in r if c)]
    if not clean_rows:
        return None, i

    max_cols = max(len(r) for r in clean_rows)
    # Pad rows
    padded = []
    for r in clean_rows:
        while len(r) < max_cols:
            r.append("")
        padded.append(r)

    # Build table data with Paragraphs
    tdata = []
    for ri, row in enumerate(padded):
        prow = []
        for ci, cell in enumerate(row):
            cell = clean(cell)
            style = make_style(f"TC_{ri}_{ci}",
                fontSize=8.5 if ri > 0 else 9,
                fontName="Helvetica-Bold" if ri == 0 else "Helvetica",
                textColor=WHITE if ri == 0 else DARK_TEXT,
                leading=12, spaceAfter=1)
            prow.append(Paragraph(cell, style))
        tdata.append(prow)

    col_width = (A4[0] - 3*cm) / max_cols
    t = Table(tdata, colWidths=[col_width] * max_cols, repeatRows=1)
    ts = TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), ACCENT_BLUE),
        ("TEXTCOLOR",  (0, 0), (-1, 0), WHITE),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [LIGHT_GREY, WHITE]),
        ("GRID",       (0, 0), (-1, -1), 0.3, MID_GREY),
        ("VALIGN",     (0, 0), (-1, -1), "TOP"),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING",   (0, 0), (-1, -1), 5),
    ])
    t.setStyle(ts)
    return t, i


def parse_checklist_item(line):
    """Return (checked, text) for - [ ] or - [x] lines."""
    m = re.match(r'\s*-\s*\[( |x|X)\]\s*(.*)', line)
    if m:
        checked = m.group(1).lower() == 'x'
        return checked, m.group(2).strip()
    return None, None


# ── Main Parser ───────────────────────────────────────────────────────────────

def md_to_flowables(md_text):
    flowables = []
    lines = md_text.split("\n")
    i = 0
    in_code_block = False
    code_lines = []

    while i < len(lines):
        line = lines[i]

        # ── Code block ───────────────────────────────────────────────────────
        if line.strip().startswith("```"):
            if in_code_block:
                # End code block
                code_text = "\n".join(code_lines)
                if code_text.strip():
                    flowables.append(Paragraph(code_text.replace("\n", "<br/>"), code_style))
                code_lines = []
                in_code_block = False
            else:
                in_code_block = True
            i += 1
            continue

        if in_code_block:
            code_lines.append(line.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))
            i += 1
            continue

        # ── Horizontal rule ──────────────────────────────────────────────────
        if re.match(r'^---+$', line.strip()):
            flowables.append(hr())
            i += 1
            continue

        # ── Markdown table ───────────────────────────────────────────────────
        if is_table_row(line):
            table_flowable, i = parse_md_table(lines, i)
            if table_flowable:
                flowables.append(Spacer(1, 4))
                flowables.append(table_flowable)
                flowables.append(Spacer(1, 6))
            continue

        # ── Headings ─────────────────────────────────────────────────────────
        if line.startswith("# ") and not line.startswith("## "):
            flowables.append(PageBreak())
            flowables.append(Paragraph(clean(line[2:]), h1))
            flowables.append(hr(ACCENT_BLUE, 1.5))
            i += 1
            continue

        if line.startswith("## "):
            flowables.append(Spacer(1, 6))
            flowables.append(Paragraph(clean(line[3:]), h2))
            flowables.append(hr(MID_GREY, 0.4))
            i += 1
            continue

        if line.startswith("### "):
            flowables.append(Paragraph(clean(line[4:]), h3))
            i += 1
            continue

        if line.startswith("#### "):
            s = make_style("H4x", fontSize=10, fontName="Helvetica-Bold",
                textColor=DARK_TEXT, spaceBefore=6, spaceAfter=2, leftIndent=16)
            flowables.append(Paragraph(clean(line[5:]), s))
            i += 1
            continue

        # ── Block quote (Note) ────────────────────────────────────────────────
        if line.startswith("> "):
            flowables.append(Paragraph(clean(line[2:]), note_style))
            i += 1
            continue

        # ── Checklist items ──────────────────────────────────────────────────
        checked, item_text = parse_checklist_item(line)
        if item_text is not None:
            symbol = "☑ " if checked else "☐ "
            col = ACCENT_GREEN if checked else ACCENT_RED
            s = make_style("Chk", fontSize=9, fontName="Helvetica",
                textColor=col, leftIndent=24, firstLineIndent=-12, spaceAfter=2, leading=13)
            flowables.append(Paragraph(symbol + clean(item_text), s))
            i += 1
            continue

        # ── Bullet lists ─────────────────────────────────────────────────────
        m = re.match(r'^(\s*)[-*]\s+(.*)', line)
        if m:
            indent = len(m.group(1))
            text = m.group(2)
            # Status badges
            if text.startswith("**Status**:") or text.startswith("- **Status**:"):
                flowables.append(status_para("• " + clean(text)))
            else:
                lvl_indent = 20 + indent * 8
                s = make_style(f"Bul_{i}", fontSize=9, fontName="Helvetica",
                    textColor=DARK_TEXT, leftIndent=lvl_indent,
                    firstLineIndent=-10, spaceAfter=2, leading=13)
                flowables.append(Paragraph("• " + clean(text), s))
            i += 1
            continue

        # ── Numbered lists ───────────────────────────────────────────────────
        m2 = re.match(r'^(\s*)(\d+)\.\s+(.*)', line)
        if m2:
            indent = len(m2.group(1))
            num = m2.group(2)
            text = m2.group(3)
            lvl_indent = 20 + indent * 8
            s = make_style(f"Num_{i}", fontSize=9, fontName="Helvetica",
                textColor=DARK_TEXT, leftIndent=lvl_indent,
                firstLineIndent=-12, spaceAfter=2, leading=13)
            flowables.append(Paragraph(f"{num}. " + clean(text), s))
            i += 1
            continue

        # ── Plain paragraph ──────────────────────────────────────────────────
        stripped = line.strip()
        if stripped:
            # Detect bold metadata lines at top
            if re.match(r'^\*\*[A-Z][^*]+\*\*:', stripped):
                s = make_style("Meta", fontSize=9.5, fontName="Helvetica-Bold",
                    textColor=MID_GREY, spaceAfter=2, leftIndent=0)
                flowables.append(Paragraph(clean(stripped), s))
            else:
                flowables.append(Paragraph(clean(stripped), body))
        else:
            flowables.append(Spacer(1, 4))
        i += 1

    return flowables


# ── Cover Page ────────────────────────────────────────────────────────────────

def build_cover():
    items = []
    items.append(Spacer(1, 3*cm))

    # Top accent bar
    items.append(Table([[""]], colWidths=[A4[0]-3*cm], rowHeights=[8]))
    items[-1].setStyle(TableStyle([("BACKGROUND", (0,0), (-1,-1), ACCENT_BLUE)]))

    items.append(Spacer(1, 0.7*cm))
    items.append(Paragraph("SHUTTLER", cover_title))
    items.append(Paragraph("Badminton Academy Management System", cover_sub))
    items.append(Spacer(1, 0.4*cm))

    items.append(Table([[""]], colWidths=[A4[0]-3*cm], rowHeights=[2]))
    items[-1].setStyle(TableStyle([("BACKGROUND", (0,0), (-1,-1), LIGHT_GREY)]))

    items.append(Spacer(1, 0.5*cm))
    items.append(Paragraph("Production Readiness Plan", make_style("PT",
        fontSize=20, fontName="Helvetica-Bold",
        textColor=DARK_TEXT, alignment=TA_CENTER, spaceAfter=4)))
    items.append(Spacer(1, 0.3*cm))

    meta_data = [
        ("Document Version", "1.1"),
        ("Created", "February 2026"),
        ("Last Updated", "February 2026"),
        ("App Version", "1.0.0+1"),
        ("Target", "App Store (iOS) + Google Play Store + Cloud Backend"),
    ]
    for label, val in meta_data:
        items.append(Paragraph(f"<b>{label}:</b>  {val}", cover_meta))

    items.append(Spacer(1, 1.5*cm))

    # Status summary box
    summary_data = [
        [Paragraph("<b>Category</b>", make_style("SH", fontSize=9, fontName="Helvetica-Bold", textColor=WHITE)),
         Paragraph("<b>Status</b>", make_style("SH2", fontSize=9, fontName="Helvetica-Bold", textColor=WHITE))],
        ["Core App Features",      "~85% Complete"],
        ["Security & Auth",        "~15% Complete — JWT MISSING"],
        ["IDOR Protection",        "0% — CRITICAL GAP"],
        ["Usage Capping",          "0% — Not Implemented"],
        ["CI/CD Pipeline",         "0% — Not Configured"],
        ["Cloud Infrastructure",   "0% — Running on localhost"],
        ["Automated Testing",      "~5% Complete"],
        ["Privacy & Legal",        "0% — No Privacy Policy"],
        ["Overall Readiness",      "~30%"],
    ]
    col_w = [(A4[0]-3*cm)*0.55, (A4[0]-3*cm)*0.45]
    t = Table(summary_data, colWidths=col_w)
    ts = TableStyle([
        ("BACKGROUND",    (0, 0), (-1, 0), ACCENT_BLUE),
        ("TEXTCOLOR",     (0, 0), (-1, 0), WHITE),
        ("ROWBACKGROUNDS",(0, 1), (-1, -1), [LIGHT_GREY, WHITE]),
        ("TEXTCOLOR",     (1, 2), (1, 2), ACCENT_RED),   # IDOR
        ("TEXTCOLOR",     (1, 3), (1, 3), ACCENT_RED),   # Capping
        ("TEXTCOLOR",     (1, 4), (1, 4), ACCENT_RED),   # CI/CD
        ("TEXTCOLOR",     (1, 5), (1, 5), ACCENT_RED),   # Infra
        ("TEXTCOLOR",     (1, -1), (1, -1), ACCENT_ORANGE), # Overall
        ("FONTNAME",      (0, -1), (-1, -1), "Helvetica-Bold"),
        ("FONTSIZE",      (0, 0), (-1, -1), 9),
        ("GRID",          (0, 0), (-1, -1), 0.3, MID_GREY),
        ("TOPPADDING",    (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING",   (0, 0), (-1, -1), 8),
    ])
    t.setStyle(ts)
    items.append(t)

    items.append(Spacer(1, 1*cm))
    items.append(Paragraph(
        "<b>⚠ Critical Warning:</b> The app currently has NO JWT tokens and NO IDOR protection. "
        "Any user can access any other user's data by guessing an ID. "
        "DO NOT put real user data in production until Phase A security is complete.",
        note_style))

    items.append(PageBreak())
    return items


# ── Page numbering ────────────────────────────────────────────────────────────

def on_page(canvas, doc):
    canvas.saveState()
    # Footer bar
    canvas.setFillColor(LIGHT_GREY)
    canvas.rect(0, 0, A4[0], 1.2*cm, fill=True, stroke=False)
    canvas.setFillColor(MID_GREY)
    canvas.setFont("Helvetica", 8)
    canvas.drawCentredString(A4[0]/2, 0.45*cm, f"Shuttler — Production Readiness Plan  |  Page {doc.page}")
    canvas.drawString(1.5*cm, 0.45*cm, "CONFIDENTIAL")
    canvas.drawRightString(A4[0]-1.5*cm, 0.45*cm, "v1.1 • February 2026")
    canvas.restoreState()


# ── Build PDF ─────────────────────────────────────────────────────────────────

def build_pdf(md_path, out_path):
    with open(md_path, "r", encoding="utf-8") as f:
        md_text = f.read()

    doc = SimpleDocTemplate(
        out_path,
        pagesize=A4,
        leftMargin=1.5*cm,
        rightMargin=1.5*cm,
        topMargin=1.5*cm,
        bottomMargin=1.5*cm,
        title="Shuttler — Production Readiness Plan",
        author="Development Team",
        subject="Production Readiness Assessment",
    )

    story = []
    story.extend(build_cover())
    story.extend(md_to_flowables(md_text))

    doc.build(story, onFirstPage=on_page, onLaterPages=on_page)
    print(f"PDF saved: {out_path}")


if __name__ == "__main__":
    import os
    base = os.path.dirname(os.path.abspath(__file__))
    md_path  = os.path.join(base, "PRODUCTION_READINESS_PLAN.md")
    out_path = os.path.join(base, "PRODUCTION_READINESS_PLAN.pdf")
    build_pdf(md_path, out_path)
