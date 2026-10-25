# Built-in Modules only, no custom Module builder

Households tailor the app by switching built-in Modules (Shopping List, Presence, Announcements, Tasks, House Info, Meals, and later ones such as Pets) on and off. They cannot define their own Modules. Each built-in Module stays opinionated about its domain (Tasks know about schedules and Assignees, Meals about upcoming meals), which keeps the app low-friction. A generic builder would push the data model toward schema-less structures and make every Module feel like a weaker spreadsheet.

## Considered Options

- **Custom Module builder**: Members define their own Modules with custom fields. Rejected for v1 and launch for the reasons above.
- **A built-in "Custom List" Module**: several named checklists. Not built now, but kept as the preferred answer if real users ask for "custom" Modules, since it covers most of that need cheaply.
