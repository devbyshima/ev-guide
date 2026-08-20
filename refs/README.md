# Reference designs

The four UI reference screenshots for EV Guide go here.

They are the **source of truth for the product's styling**: the palette, the
type scale, the radii, the spacing, the component geometry and the state
grammar are implemented 1:1 with no deliberate deviations, under the studio's
standing rule.

**They are not the source of truth for layout or information architecture.**
That changed on 2026-08-20
([ADR-0013](../docs/adr/0013-charger-finder-redesign.md), amending locked
decision 16): the reference is a Kigali car-rental app, and its IA was never
about finding a charger, so screen structure is now decided on its merits for a
Rwandan driver. **Do not read a layout difference between these screenshots and
the driver app as a defect.** Four knowing *styling* deviations exist and are
enumerated in SPEC.md decision 22; anything beyond those four is a bug.

Ticket 01 was blocked until these landed, and ticket 17 (screen inventory +
design system) on ticket 01. Both are long closed; the note is kept because it
explains why the file exists.

Name them `01.png` … `04.png` in the order they were originally shared.
