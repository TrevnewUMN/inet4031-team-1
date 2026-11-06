# Week 8 - Part 4: Failure Simulation and Recovery

## Objective
Simulate data loss, restore files using Restic, verify data integrity, and measure recovery time.

## Recovery Test
I created a test directory on the university server and backed it up to the team's Restic repository in MinIO.

I simulated data loss by deleting the test directory, then restored it from snapshot 546682a7.

## Results
- Snapshot ID: 546682a7
- Test directory: /home/abdul785/recovery-test-team1
- Recovery time: 1 second
- Restored data: 30 bytes
- SHA-256 verification: PASSED
- Recovery status: Successful

## Verification
After restoring the directory, I ran:

    sha256sum -c ~/original-checksum.txt

Result:

    /home/abdul785/recovery-test-team1/test.txt: OK

The checksum matched the original file, confirming that the restored data was intact.

## Limitations
The Flask application container uses a read-only root filesystem, so the recovery simulation was performed in an isolated directory on the university server rather than inside the application container.

The team's RTO target has not yet been confirmed. The measured recovery time was 1 second, but the RTO comparison remains pending.

## Conclusion
The Restic recovery test was successful. The deleted test directory was restored, and its data integrity was verified using SHA-256.
