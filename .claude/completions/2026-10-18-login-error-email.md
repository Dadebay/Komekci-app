# Login error email report

- On the login phone screen, a failed `POST /auth/otp/request` now reveals an
  email report action and dismisses the keyboard so the error is readable.
- The prepared message is addressed to `dadebaygurbanow333@gmail.com` and
  includes UTC time, endpoint/method, masked phone, HTTP status, error code,
  error detail, and platform version. It excludes OTP codes and tokens.
- The action opens the device email app for the user to review and send. If no
  email app can open, it copies the report and shows a snackbar.
- Verified targeted Flutter analysis with no issues and a successful debug APK
  build. No device run or actual email send was performed.
