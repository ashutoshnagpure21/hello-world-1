
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Velocity Motors | Drive Your Dreams</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --red: #ff3b45;
            --dark: #090b10;
            --panel: #131720;
            --muted: #a1a8b5;
            --white: #f8fafc;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background: var(--dark);
            color: var(--white);
            line-height: 1.6;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        .navbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px 8%;
            border-bottom: 1px solid #252a35;
            background: rgba(9, 11, 16, 0.96);
        }

        .logo {
            font-size: 25px;
            font-weight: 900;
            letter-spacing: 1px;
        }

        .logo span {
            color: var(--red);
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 28px;
            color: #c5cad4;
            font-size: 14px;
        }

        .nav-links a:hover {
            color: var(--red);
        }

        .btn {
            display: inline-block;
            border: none;
            border-radius: 7px;
            background: var(--red);
            color: white;
            padding: 12px 22px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.25s;
        }

        .btn:hover {
            background: #df2633;
            transform: translateY(-2px);
        }

        .hero {
            min-height: 570px;
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            align-items: center;
            gap: 45px;
            padding: 75px 8%;
            background:
                radial-gradient(ellipse at 75% 40%, #4a1720 0%, transparent 48%),
                linear-gradient(120deg, #090b10, #17111a);
        }

        .eyebrow {
            color: var(--red);
            text-transform: uppercase;
            letter-spacing: 4px;
            font-size: 12px;
            font-weight: bold;
            margin-bottom: 18px;
        }

        h1 {
            font-size: clamp(42px, 5.4vw, 72px);
            line-height: 1.08;
            letter-spacing: -2px;
            margin-bottom: 22px;
        }

        h1 span {
            color: var(--red);
        }

        .hero p {
            color: var(--muted);
            max-width: 480px;
            margin-bottom: 30px;
        }

        .hero-buttons {
            display: flex;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
        }

        .secondary-btn {
            border: 1px solid #555c6b;
            border-radius: 7px;
            padding: 11px 20px;
            color: white;
        }

        .secondary-btn:hover {
            border-color: var(--red);
        }

        .hero-image {
            width: 100%;
            min-height: 320px;
            object-fit: cover;
            border-radius: 18px;
            border: 1px solid #38303a;
            box-shadow: 0 25px 70px #0009;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
            margin-top: 45px;
            max-width: 450px;
        }

        .stat strong {
            display: block;
            font-size: 25px;
        }

        .stat small {
            color: var(--muted);
        }

        section {
            padding: 75px 8%;
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: end;
            gap: 20px;
            margin-bottom: 32px;
        }

        .section-heading h2 {
            font-size: 34px;
        }

        .section-heading p {
            color: var(--muted);
        }

        .cars {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 24px;
        }

        .car-card {
            background: var(--panel);
            border: 1px solid #292e39;
            border-radius: 13px;
            overflow: hidden;
            transition: 0.3s;
        }

        .car-card:hover {
            transform: translateY(-7px);
            border-color: var(--red);
        }

        .car-card img {
            width: 100%;
            height: 205px;
            object-fit: cover;
            display: block;
        }

        .car-info {
            padding: 22px;
        }

        .car-info h3 {
            font-size: 21px;
            margin-bottom: 5px;
        }

        .car-info p {
            color: var(--muted);
            font-size: 14px;
            margin-bottom: 16px;
        }

        .car-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
        }

        .price {
            color: var(--red);
            font-size: 19px;
            font-weight: bold;
        }

        .explore {
            font-size: 13px;
            font-weight: bold;
        }

        .login-section {
            background: linear-gradient(130deg, #17111a, #0d1119);
            display: grid;
            grid-template-columns: 1fr 0.8fr;
            align-items: center;
            gap: 55px;
        }

        .login-copy h2 {
            font-size: 42px;
            line-height: 1.15;
            margin-bottom: 18px;
        }

        .login-copy p {
            color: var(--muted);
            max-width: 440px;
        }

        .login-card {
            background: #151923;
            border: 1px solid #303543;
            padding: 32px;
            border-radius: 15px;
            box-shadow: 0 20px 60px #0004;
        }

        .login-card h3 {
            font-size: 25px;
            margin-bottom: 5px;
        }

        .login-card .sub {
            color: var(--muted);
            font-size: 14px;
            margin-bottom: 25px;
        }

        .field {
            margin-bottom: 17px;
        }

        .field label {
            display: block;
            font-size: 13px;
            margin-bottom: 7px;
            color: #d6d9e1;
        }

        .field input {
            width: 100%;
            padding: 13px 14px;
            background: #0b0e14;
            color: white;
            border: 1px solid #363c49;
            border-radius: 7px;
            outline: none;
        }

        .field input:focus {
            border-color: var(--red);
        }

        .login-card .btn {
            width: 100%;
            margin-top: 5px;
        }

        .login-note {
            color: var(--muted);
            font-size: 12px;
            margin-top: 14px;
            text-align: center;
        }

        .login-message {
            color: #ff7d86;
            font-size: 13px;
            margin-top: 12px;
        }

        footer {
            padding: 27px 8%;
            border-top: 1px solid #252a35;
            display: flex;
            justify-content: space-between;
            gap: 15px;
            flex-wrap: wrap;
            color: var(--muted);
            font-size: 13px;
        }

        @media (max-width: 850px) {
            .hero, .login-section {
                grid-template-columns: 1fr;
            }

            .hero {
                padding-top: 55px;
            }

            .cars {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .nav-links {
                gap: 13px;
            }
        }

        @media (max-width: 560px) {
            .navbar {
                padding: 18px 5%;
                flex-wrap: wrap;
                gap: 16px;
            }

            .nav-links {
                width: 100%;
                justify-content: space-between;
                font-size: 12px;
            }

            .nav-links .btn {
                padding: 8px 12px;
            }

            .hero, section {
                padding: 45px 5%;
            }

            .cars {
                grid-template-columns: 1fr;
            }

            .section-heading {
                align-items: start;
                flex-direction: column;
            }

            .stats {
                gap: 10px;
            }

            .login-card {
                padding: 23px;
            }

            footer {
                padding: 22px 5%;
            }
        }
    </style>
</head>

<body>

    <nav class="navbar">
        <a href="#home" class="logo">VELOCITY<span>.</span></a>

        <div class="nav-links">
            <a href="#home">Home</a>
            <a href="#cars">Our Cars</a>
            <a href="#login">Login</a>
            <a href="#login" class="btn">Get Started</a>
        </div>
    </nav>

    <header class="hero" id="home">
        <div>
            <div class="eyebrow">The art of driving</div>

            <h1>Drive Your<br><span>Dreams.</span></h1>

            <p>
                Discover exceptional automobiles crafted for those
                who expect more. Find your perfect drive with
                Velocity Motors.
            </p>

            <div class="hero-buttons">
                <a href="#cars" class="btn">Explore Collection ↗</a>
                <a href="#login" class="secondary-btn">Member Login</a>
            </div>

            <div class="stats">
                <div class="stat">
                    <strong>120+</strong>
                    <small>Premium Cars</small>
                </div>
                <div class="stat">
                    <strong>50+</strong>
                    <small>Brands</small>
                </div>
                <div class="stat">
                    <strong>4.9/5</strong>
                    <small>Experience</small>
                </div>
            </div>
        </div>

        <img
            class="hero-image"
            src="https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1100&q=85"
            alt="Premium luxury sports car"
        >
    </header>

    <section id="cars">
        <div class="section-heading">
            <div>
                <div class="eyebrow">Our collection</div>
                <h2>Find Your Perfect Drive.</h2>
                <p>Performance meets personality.</p>
            </div>
            <a href="#login" class="secondary-btn">View All Cars ↗</a>
        </div>

        <div class="cars">

            <article class="car-card">
                <img
                    src="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=850&q=80"
                    alt="Luxury sports coupe"
                    loading="lazy"
                >
                <div class="car-info">
                    <h3>911 Carrera</h3>
                    <p>Sports Coupe · Automatic</p>
                    <div class="car-bottom">
                        <span class="price">₹1.99 Cr*</span>
                        <a href="#login" class="explore">Explore ↗</a>
                    </div>
                </div>
            </article>

            <article class="car-card">
                <img
                    src="https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=850&q=80"
                    alt="Luxury SUV"
                    loading="lazy"
                >
                <div class="car-info">
                    <h3>Urban Explorer</h3>
                    <p>Luxury SUV · Premium</p>
                    <div class="car-bottom">
                        <span class="price">₹85 Lakh*</span>
                        <a href="#login" class="explore">Explore ↗</a>
                    </div>
                </div>
            </article>

            <article class="car-card">
                <img
                    src="https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=850&q=80"
                    alt="Luxury performance sedan"
                    loading="lazy"
                >
                <div class="car-info">
                    <h3>Executive M</h3>
                    <p>Performance Sedan · Sport</p>
                    <div class="car-bottom">
                        <span class="price">₹95 Lakh*</span>
                        <a href="#login" class="explore">Explore ↗</a>
                    </div>
                </div>
            </article>

        </div>
    </section>

    <section class="login-section" id="login">
        <div class="login-copy">
            <div class="eyebrow">Your journey starts here</div>
            <h2>Luxury is not a destination.<br><span style="color:#ff3b45">It's a lifestyle.</span></h2>
            <p>
                Sign in to your member account to continue your journey,
                explore our collection, and discover your next dream car.
            </p>
        </div>

        <div class="login-card">
            <h3>Welcome Back 👋</h3>
            <p class="sub">Sign in to Velocity Motors</p>

            <form action="login" method="post" id="loginForm">
                <div class="field">
                    <label for="username">Username or Email</label>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        placeholder="Enter your username"
                        autocomplete="username"
                        required
                    >
                </div>

                <div class="field">
                    <label for="password">Password</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder="Enter your password"
                        autocomplete="current-password"
                        required
                    >
                </div>

                <button type="submit" class="btn">Sign In →</button>

                <p class="login-note">
                    Secure access to your automotive experience.
                </p>

                <p class="login-message" id="loginMessage" aria-live="polite"></p>
            </form>
        </div>
    </section>

    <footer>
        <a href="#home" class="logo">VELOCITY<span>.</span></a>
        <p>© 2026 Velocity Motors. All rights reserved.</p>
        <p>*Prices are illustrative and not live offers.</p>
    </footer>

</body>
</html>
