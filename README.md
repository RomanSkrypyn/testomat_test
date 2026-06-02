# README

* ### Run the setup script:
    `bin/setup`


* ### Start the local server:
    `bin/dev`
---

## MEILISEARCH Configuration

### Environment Variables

Update your `.env` file with the following variables:

```bash
# MEILISEARCH Configuration
MEILISEARCH_HOST=your_meilisearch_host
MEILISEARCH_API_KEY=your_meilisearch_api_key
```
## Create Index for Comments

Run `Comment.index` in the Rails console to create the index for comments in Meilisearch.

---

## SMTP Configuration for Mailers

### Overview
This application uses Rails mailers for sending emails (e.g., user confirmations, password resets). Email delivery is configured through SMTP settings.

### Environment Variables
Update your `.env` file with the following variables:

```bash
# SMTP Configuration
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

### Configuration File
The SMTP settings are configured in `config/environments/production.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_ADDRESS'],
  port: ENV['SMTP_PORT'],
  authentication: ENV['SMTP_AUTHENTICATION'],
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'] == 'true'
}
```

### Example for Gmail
```bash
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password  # Use "App Password" from Google Account Security
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

**Setup Steps:**
1. Enable 2-Factor Authentication on your Google Account
2. Go to [Google Account Security](https://myaccount.google.com/security)
3. Create an "App Password" for Gmail
4. Use this password in `SMTP_PASSWORD`
