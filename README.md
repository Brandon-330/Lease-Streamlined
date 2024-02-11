# Lease Streamlined

Lease Streamlined is an apartments rental management web application with a focus for rental management companies.

## Description

Lease Streamlined is designed for small and midsized rental management companies. LS is able to track various unique building names and their respective apartments. This application also tracks tenants unique to each apartment within a building. For future considerations, this application added a separate tenants relation in the event detailed tenant information is requested per the client/user.

Each building can be updated and deleted accordingly. Each building has the ability to evict all tenants in the event a renovation is required. Apartments can be updated and deleted as well, which includes its apartment number, rent, and tenant name (if any). Only admin users are able to modify and view building and apartment information.

For viewing purposes, this application restricts 5 buildings and/or apartments per page. All listed buildings are organized in alphabetical order, meanwhile apartments are organized from most rent to least rent for the financial purposes of the user. All user input has been sanitized to prevent HTML/JS/PostgreSQL injection.

As a bonus feature, this application requests for the first signup to be the admin. From there, the admin, once logged in, has the liberty to add other admin users to use the application. Once logged in, an admin has the liberty to log out. All password credentials has been encrypted with the BCrypt gem

### Limitations

Lease Streamlined has been designed with a limitation that each building name must be unique, apartment numbers must be unique, and each building has unique tenant names. To avoid this unlikely scenario, creating nicknames for tenants is an effective solution while the application is being updated to accomodate for this scenario.

## Installation

To use the application make sure to have installed the bundler gem prior to using the application.

```bash
gem install bundler
```

Once installed, run bundler on your terminal using the following command:

```bash
bundle install
```

bundler will run in accordance with the specifications presented within Gemfile.

### Running Application

This application can run by entering the following command in the terminal:

```bash
ruby rental_management.rb
```

The application can then be accessed and tested in a web browser with the following URL: "localhost:4567"

### Testing Application

This application used ruby version 3.2.2 as stated in the Gemfile. 

To test this application, this application used Google Chrome Version 121.0.6167.161 web browser.

For database purposes, this application used PostgreSQL version 16.1.

#### Possible Complications

If there is a database error, make sure the database created is named "apartments_rental_management". In addition, the database in this application attempts to sign in to PostgreSQL through the default "postgres" user (with a default "postgres" password). 

## Owner

Brandon Lima