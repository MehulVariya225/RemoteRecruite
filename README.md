
## Assumptions Made

### Technical Assumptions

1. **Minimum iOS Version**: iOS 15.0 or later
   - Assumes users have devices that support iOS 15
   - Uses Swift concurrency features (async/await)

2. **Device Support**:
   - Supports iPhone and iPad

3. **Data Persistence**:
   - Applied jobs are stored locally using UserDefaults

4. **Testing**:
   - MockJobService used for unit tests
   - Tests assume deterministic mock data

### Business Assumptions

1. **Job Data**:
   - Each job has a title, company, location, description, and salary range
   - Job IDs are unique and never reused

2. **User Behavior**:
   - User can search jobs by title, company, or location
   - User can apply to same job only once
   - User can view applied jobs history

3. **Search Functionality**:
   - Search is case-insensitive
   - Search matches partial words (e.g., "eng" matches "engineer")
   - EnhancedSearchBar provides advanced filtering options

4. **Performance Expectations**:
   - Job list loads within 2 seconds on supported devices
   - Search results appear instantly (client-side filtering)
   - App maintains 60fps during scrolling

### Data Assumptions
   - MockJobService returns predefined job listings for development
   - Real API integration can replace MockJobService later

### Known Limitations
- No real API integration yet (uses mock data)
- No push notifications for new jobs
- No dark mode support

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | Clean build: Product → Clean Build Folder (Cmd + Shift + K) |
| Can't find files | Make sure all files are added to target: File Inspector → Target Membership |
| Simulator crashes | Reset simulator: Device → Erase All Content and Settings |

## License
This project is for educational/demo purposes.
