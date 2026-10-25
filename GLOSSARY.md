# Home App

A shared space where the people living together in a home coordinate everyday household life. Built to be low-friction, available in Turkish and English.

## Language

### Households and people

**Household**:
A group of people living together who share one space in the app. A person can belong to several Households.
_Avoid_: Home, house, family, group, flat

**Member**:
A person's membership in one specific Household. The same person is a different Member in each Household they belong to.
_Avoid_: User, resident, flatmate

**Default Household**:
The Household a person's app opens to. Each person picks their own and can change it at any time.
_Avoid_: Main house, primary household, home household

**Admin**:
A Member who can switch Modules on and off, manage membership, and edit House Info. The Member who creates a Household is its first Admin and can make other Members Admins.
_Avoid_: Owner, moderator, host

**Invite**:
A shareable code or link, created by an Admin, that lets a person join a Household as a Member.
_Avoid_: Invitation email, join request

### Modules

**Module**:
A built-in feature area that a Household switches on or off to suit its needs.
_Avoid_: Section, feature, plugin, widget

**Shopping List** (Alışveriş Listesi):
The Module for things the Household needs to buy.

**Category**:
A heading on the Shopping List that groups Items. There are exactly two: Market and General. The Member adding an Item picks its Category.
_Avoid_: Section, aisle, list

**Item**:
One thing to buy on the Shopping List: a name plus an optional note (brand, quantity and so on).
_Avoid_: Product, entry

**Favorite**:
A Shopping List item, with its Category, that the Household saves so anyone can add it again with one tap.
_Avoid_: Saved item, staple, template

**Presence** (Evde / Dışarıda):
The Module showing whether each Member is at home, out, or not specified, together with when they last set it. Always set manually by the Member.
_Avoid_: Status, location, check-in

**Announcements** (Duyurular):
The Module for messages addressed to the whole Household. Each Announcement expires after a time chosen when it is posted, unless an Admin pins it, and can be deleted early by its author or an Admin. Lasting facts about the home belong in House Info, not in a pinned Announcement.
_Avoid_: Posts, notices, chat

**Hangout** (Etkinlik):
An Announcement that the author opens for joining, such as a night walk or a movie in the living room. Members join with "I'm in" and can undo it. Everyone sees who has joined. Otherwise it follows the same rules as any Announcement.
_Avoid_: Invite (that means joining a Household), event, plan, RSVP

**Tasks** (Ev İşleri):
The Module for household jobs that need doing, such as emptying the dishwasher or vacuuming the living room. A Task can be one-off or recurring and may have an Assignee. Anyone in the Household can complete any Task.
_Avoid_: Chores, to-dos, jobs

**Recurring Task**:
A Task that comes due on a fixed calendar schedule (for example every Monday, or every day), regardless of when it was last completed.
_Avoid_: Repeating task, routine

**Assignee**:
The Member a Task is assigned to, either for a single occurrence or permanently for a recurring Task.
_Avoid_: Owner, responsible

**Completion**:
The record that a Task was done, by which Member and when.
_Avoid_: Check-off, done mark

**House Info** (Ev Bilgileri):
The Module for reference facts about the home, such as bin collection day, the wifi password or washing machine modes.
_Avoid_: Notes, wiki, details

**Meals** (Yemek):
The Module where each Member says whether they will eat at home for an upcoming meal. The Household chooses which meals it asks about (for example only dinner). Answers reset to "not said" each day. Separate from Presence: Presence is about now, Meals is a plan.

**Meal Reminder**:
A notification any Member can send to the Members who have not yet answered for a meal. Never sent automatically.
_Avoid_: Daily prompt, meal poll
_Avoid_: Dinner, attendance, RSVP
