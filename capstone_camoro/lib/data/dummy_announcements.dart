import '../models/announcement.dart';

final dummyAnnouncements = <Announcement>[
  Announcement(
    id: 1,
    createdAt: DateTime(2026, 11, 10, 9),
    title: 'Finals Week Library Hours',
    description:
        'Need a quiet place to finish your reviewer? The main library will '
        'stay open until 8:00 PM from November 23 to 27. Bring your student '
        'ID to enter. You can reserve a group study table at the circulation '
        'desk before 5:00 PM.',
    audience: AnnouncementAudience.everyone,
  ),
  Announcement(
    id: 2,
    createdAt: DateTime(2026, 11, 11, 9),
    title: 'Club Fair in the Main Courtyard',
    description:
        'Drop by the main courtyard on November 25 from 11:00 AM to 3:00 PM '
        'to meet the campus clubs. Look for the registration table by the '
        'covered walk to pick up a booth map. First-year and returning '
        'students are welcome to sign up.',
    audience: AnnouncementAudience.everyone,
  ),
  Announcement(
    id: 3,
    createdAt: DateTime(2026, 11, 12, 9),
    title: 'CMBA Scholarship Applications Are Open',
    description:
        'Applications for the second-semester CMBA student assistance grant '
        'are open until 4:00 PM on December 4. Pick up a form at the CMBA '
        'Dean’s Office and submit it with a copy of your latest grades and '
        'registration form.',
    audience: AnnouncementAudience.cmba,
  ),
  Announcement(
    id: 4,
    createdAt: DateTime(2026, 11, 13, 9),
    title: 'Computer Lab 2 Closed for Maintenance',
    description:
        'Computer Lab 2 will be closed on November 28 from 8:00 AM to noon '
        'for software updates. If you need a workstation for your project, '
        'Lab 1 will be open on the second floor. Bring your student ID and '
        'sign in with the lab assistant.',
    audience: AnnouncementAudience.ccs,
  ),
  Announcement(
    id: 5,
    createdAt: DateTime(2026, 11, 14, 9),
    title: 'CCJ Volunteers Needed for Campus Clean-Up',
    description:
        'Join the CCJ Student Council on November 28 for a clean-up around '
        'the covered court and campus walkways. Meet at the main gate at '
        '8:00 AM in closed shoes. The council will provide gloves and sacks. '
        'Bring a refillable water bottle.',
    audience: AnnouncementAudience.ccj,
  ),
  Announcement(
    id: 6,
    createdAt: DateTime(2026, 11, 15, 9),
    title: 'Basic Education Student ID Replacement',
    description:
        'Students with lost or damaged IDs can request a replacement at the '
        'Basic Education Office on November 26 and 27, from 1:00 to 4:00 PM. '
        'Bring your registration slip and, if you still have it, your damaged '
        'ID. Class advisers can help students who need a registration copy.',
    audience: AnnouncementAudience.basicEducation,
  ),
  Announcement(
    id: 7,
    createdAt: DateTime(2026, 11, 16, 9),
    title: 'CASE Workshop on Finding and Citing Sources',
    description:
        'Working on a research paper? Bring a draft or a list of sources to '
        'the library seminar room on November 25 at 2:00 PM. The library '
        'team will show you how to search the journal databases and clean '
        'up your reference list. Sign up at the library desk by November 24.',
    audience: AnnouncementAudience.caseCollege,
  ),
  Announcement(
    id: 8,
    createdAt: DateTime(2026, 11, 17, 9),
    title: 'CNAHS Intramurals Team Registration',
    description:
        'Team captains can submit rosters for volleyball, basketball, and '
        'badminton at the Sports Office by 4:00 PM on November 27. Include '
        'each player’s full name and section. Students who still need a team '
        'can sign up individually at the CNAHS Student Council desk.',
    audience: AnnouncementAudience.cnahs,
  ),
  Announcement(
    id: 9,
    createdAt: DateTime(2026, 11, 18, 9),
    title: 'Unclaimed Drafting Kits at the CEA Office',
    description:
        'Two drafting kits, a drawing tube, and a calculator were turned in '
        'after this week’s studio sessions. Check with the CEA Office by '
        'November 27 between 9:00 AM and 4:00 PM. Bring your student ID and '
        'be ready to describe the item you’re claiming.',
    audience: AnnouncementAudience.cea,
  ),
  Announcement(
    id: 10,
    createdAt: DateTime(2026, 11, 19, 9),
    title: 'Tell Us What to Improve Next Semester',
    description:
        'The end-of-term student survey is open in the student portal until '
        'December 4. It takes about five minutes and asks about class '
        'schedules, campus facilities, and student services. You’ll find it '
        'under Student Services on the portal homepage.',
    audience: AnnouncementAudience.everyone,
  ),
  Announcement(
    id: 11,
    createdAt: DateTime(2026, 11, 20, 9),
    title: 'Foundation Day Program and Gate Schedule',
    description:
        'Foundation Day is on December 4! Gates open at 7:00 AM, and the '
        'opening program starts at 8:00 AM in the covered court. Please '
        'bring your school ID and meet your class adviser at your assigned '
        'section before the program starts.\n\n'
        'Student performances begin at 10:00 AM. Food stalls in the main '
        'courtyard will be open from 11:00 AM to 3:00 PM, and the campus '
        'quiz bee starts at 1:00 PM in the library seminar room. Check in '
        'with the event marshal 15 minutes before your scheduled activity.\n\n'
        'Use the main gate for drop-off and pick-up. If it rains, courtyard '
        'activities will move to the covered walk. The Student Affairs help '
        'desk beside the covered court will post any schedule changes.',
    audience: AnnouncementAudience.everyone,
  ),
];
