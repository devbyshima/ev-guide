# 35 — The price string is two weights, and the record calls it one

Type: decision
Status: **resolved 2026-08-16** — ship both; the split is structure in `rateShort`
Blocked by: —

## Question

Not in the sweep's sixty, and not one of its four flags. Found while checking
whether file 10 §11.3 was safe to propagate into files 11 and 12 — which it was
not.

**The price string `135 000 RWF/day` is not one weight.** The amount is Bold and
the **unit tail is lighter** — and the two slots that render it use *different*
lighter weights.

## Measured

Integrated stem coverage (the §0.1 method — summed coverage across a cut, not
thresholded pixel counts), stem/cap ratio given because it is the weight
discriminant independent of size:

| Slot | Glyph | Stem | stem/cap | Weight |
| --- | --- | --- | --- | --- |
| `04` sticky, cap 36 | `F` of `RWF` | **6.92 px** | 0.192 | **Bold** |
| `04` sticky, cap 36 | `d` / `a` / `y` of `day` | **4.36 / 4.21 / 4.37 px** | 0.121 | **Regular** |
| `03` card, cap 27 | `1`, `0` of the amount | **5.19 / 5.03 px** | 0.192 / 0.186 | **Bold** |
| `03` card, cap 27 | `F` of `RWF` | **5.22 px** | 0.193 | **Bold** |
| `03` card, cap 27 | `d` / `a` of `day` | **1.65 px** | 0.061 | **ExtraLight** |

The amount and the currency are Bold in both slots. The tail after the currency
is **Regular** on the sticky bar and **ExtraLight** on the card — a two-step
difference, at 0.121 against 0.061, which is far outside measurement error.

## What the record currently says

**Three places in file 10 call the whole run Bold** — §4.1 row 15 (*"Card price
`135 000 RWF/day` … Bold"*), §7.8 (*"Price `135 000 RWF/day`, cap 36 px Bold"*)
and §11.3's measured trailer. Only the §11.3 trailer has been corrected, because
it is the one ticket 32 was about to propagate; the other two are left for this
ticket so the assignment is made once, in one place.

**File 11 §13.2 is half right**: it knows two weights exist, and assigns
**Regular** to all four consuming slots. That is right for the `04` sticky slot
and wrong for the `03` card slot.

## What must be decided

1. **Is the difference deliberate or drift?** It is the same string in the same
   product at two sizes. A deliberate reading: the card is a preview and its tail
   recedes; the sticky bar is the commitment surface and its tail stays legible.
   A drift reading: two screens authored at different times. The reference cannot
   arbitrate, and 1:1 means shipping both unless told otherwise — the same shape
   as [RAISE-11] (the heart at two colours and two sizes) and [RAISE-4] (the two
   CTAs), both of which were resolved as *ship both*.
2. **Whichever way it goes, the projection must carry it.** `rateShort` returns
   structure, never a formatted string (`domain-model.md` amendment 8), so the
   amount/tail split has to be *in* that structure — a slot cannot recover it
   from a rendered string. This is a `packages/domain` shape question, not only a
   type-scale question, and it is the reason this cannot be deferred to the build.
3. **ExtraLight at cap 27 is a legibility call.** A 1.65 px stem on `#121212`,
   read one-handed in a dim car park, is [RAISE-2]'s question again at a smaller
   size and on the one string that carries a price.

## Meanwhile

File 10 §11.3's trailer states both measurements and asserts neither assignment.
Ticket 32 marked every price-slot weight statement in files 11 and 12
`[weight unsettled: RAISE-15]` rather than propagating a single-weight
description.

## Answer

**Ruled 2026-08-16 by the founder: ship both, exactly as measured.**

### 1. Deliberate or drift — the question the reference cannot arbitrate

Resolved the way its two precedents were: **1:1 means shipping it**. [RAISE-4]
(the two CTAs differing in three properties) and [RAISE-11] (the heart at two
colours and two sizes) both closed as *ship both*, and nothing distinguishes
this case except that it is a weight rather than a colour or a size. The
"deliberate" reading — a preview tail that recedes, a commitment tail that stays
legible — is available but is not *needed*: the standing rule does not require a
rationale before reproducing what the reference does. No deviation, no
[ADR-0009] entry.

**The assignment, made once, here:**

| Slot | Amount + currency | Unit tail | stem/cap |
| --- | --- | --- | --- |
| `04` sticky bar, cap 36 | `135 000 RWF` **Bold** | `/day` **Regular** | 0.192 → 0.121 |
| `03` card, cap 27 | `135 000 RWF` **Bold** | `/day` **ExtraLight** | 0.192 → 0.061 |

### 2. Where the split lives — and it is not a new field

Ticket 35 framed this as *"the amount/tail split has to be in that structure — a
slot cannot recover it from a rendered string"*. **That is true of a rendered
string, and `rateShort` does not return one.** Under `domain-model.md`
amendment 8, re-derived at file 11 §13.2, it returns

```
{kind: 'single', rwfPerKwh} | {kind: 'from', floorRwfPerKwh} | {kind: 'none'}
```

— numbers and a discriminant. **The boundary is therefore already recoverable**,
because the slot composes the string itself from a number and a unit; there is
nothing to parse and no field to add. `packages/domain` stays free of type
decisions, which is the point of amendment 8.

What was actually owed is a **composition rule**, and it belongs in file 11
§13.2 beside the projection that feeds it:

> A price slot renders three runs: the **amount** (the projection's number,
> grouped), the **currency**, and the **unit tail**. Amount and currency are
> **Bold in every slot**. The tail's weight is the **slot's** property:
> **Regular** on `04`'s sticky bar, **ExtraLight** on the `03` card.

Recorded because the failure mode is real in the other direction: had file 10's
three single-weight statements propagated, a build would have rendered one Bold
run and the split would have been unrecoverable *in the UI layer* — not because
the projection lost it, but because nobody knew it was there.

### 3. The ExtraLight legibility call

**Shipped as measured.** A 1.65 px stem at cap 27 on `#121212` is thin, and the
founder was offered the lift to Regular explicitly and declined it: the tail is
`/day`, a unit that repeats on every card in the list, and the *price* — the
part a driver reads one-handed in a dim car park — is the **Bold** run. [RAISE-2]
is unaffected: it concerns ExtraLight carrying meaning alone, and here the
meaning is carried by the Bold amount beside it.

Recorded so this is not relitigated as an accessibility defect during the build:
it is a **known-thin, deliberately-shipped 1:1 reproduction**, and the string it
appears in never carries information not also present in a heavier weight.

### 4. What was corrected

- **File 10 §4.1** gains rows **7b** (`04` tail, Regular, stem 4.31) and **15b**
  (`03` tail, ExtraLight, stem 1.65); row 15's label is narrowed to the Bold run.
- **File 10 §7.8** states both weights instead of "cap 36 px Bold".
- **File 10 §11.3**'s trailer already stated both measurements and asserted
  neither assignment; it now points here.
- **File 11 §13.2**'s blanket Regular is wrong for the `03` card slot and is
  corrected with the rest of the `[weight unsettled: RAISE-15]` marks.
