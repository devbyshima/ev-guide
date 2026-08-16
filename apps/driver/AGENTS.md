# Expo HAS CHANGED

Read the exact versioned docs at https://docs.expo.dev/versions/v57.0.0/ before writing any code.

## EV Guide notes

This app talks **only** to `@ev-guide/data`'s protocols (ADR-0005). It must not
import the mock directly outside `App.tsx`'s composition root, and it must not
compose availability strings: those come from `@ev-guide/domain`'s grammar,
which is the one place the display laws are enforced.

`packages/ui` currently exports tokens only; components land next.
