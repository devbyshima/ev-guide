# 04 — What do CarPlay and Android Auto actually require of an EV-charging app?

Type: research
Status: open
Blocked by: —

## Question

Both car integrations are in the spec, out of the first build. This ticket
establishes exactly what they demand, so the data model and the entitlement
applications are shaped correctly from the start rather than retrofitted.

For **CarPlay**: confirm the EV-charging entitlement
(`com.apple.developer.carplay-charging`) is the right one and that EV Guide
qualifies; the application process, what Apple asks for, and realistic approval
timelines; which `CPTemplate` types a charging app may use and what data shape
each expects; the review criteria an app must pass; and precisely where the
boundary sits between the charging entitlement and the far harder
`carplay-navigation` one.

For **Android Auto**: the equivalent Car App Library category, its template
set, the Play Console approval path, quality guidelines, and testing
requirements.

Note anything that constrains the *phone* app's model — if the car templates
need per-connector availability in a particular shape, that shape propagates
backwards into the schema and must be known before 09 and 19.
