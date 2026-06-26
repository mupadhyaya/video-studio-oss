# 🎥 Video Studio OSS

Video Studio OSS is a fully automated AI video generation pipeline, designed as a flexible playground for creators to generate engaging YouTube videos, experiment, and customize the workflow to their convenience. 

You provide a syllabus (`curriculum.txt`), and the engine drafts engaging scripts, generates presentation slide visuals via Pillow/MoviePy (with dynamic animations!), creates voiceovers using Edge-TTS, and composites it all together into a final MP4 video. 

**Model Flexibility**: While the default pipeline uses the Gemini API, you can easily swap this out to use the new `google-genai` CLI or any other alternative LLM to generate the script JSON files, depending on your setup and version availability.
## 🚀 Getting Started

### 1. Prerequisites
- Python 3.10+
- `ffmpeg` installed on your system (`brew install ffmpeg` or `apt-get install ffmpeg`)

### 2. Installation
We highly recommend using a virtual environment for development:
```bash
git clone https://github.com/mupadhyaya/video-studio-oss.git
cd video-studio-oss
python3 -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
pip install -r requirements.txt
```

### 3. Environment Variables
Copy the example configuration file:
```bash
cp .env.example .env
```
Open `.env` and configure:
1. `SERIES_NAME`: The name of your learning series.
2. `GEMINI_API_KEY`: Get one for free from Google AI Studio.
3. `YOUTUBE_OAUTH_TOKEN`: (Optional) If you want to automatically upload to YouTube.

### 4. Setup your Curriculum
Edit `curriculum.txt` and add a list of topics you want to generate videos for (one topic per line). 
You can also reference other text files (e.g. `python_basics.txt`) to nest your curriculum!

## 🎬 Generating a Video Locally

Run the pipeline in two steps:

**Step 1: Write the Script**
```bash
python generate_daily_script.py --day 1
```
This queries Gemini to generate a full bilingual (English & Hindi) storyboard, visual directives, and narration. It saves the output as a JSON file.

**Step 2: Render the Video**
```bash
python run_pipeline.py --day 1
```
This parses the JSON, renders the slides, synthesizes the audio, and uses `ffmpeg/moviepy` to compile the final `.mp4` files!

If you provided a `YOUTUBE_OAUTH_TOKEN`, it will automatically upload the videos as private drafts to your channel and attach a custom thumbnail!

## 🤖 Automating with GitHub Actions
Check out the `examples/github_action_template.yml` file to see how you can set this up to run automatically on a cron schedule!

## 🤝 Contributing

We welcome contributions! Whether it's adding new animations, integrating alternative LLMs, or fixing bugs, feel free to raise a Pull Request.

### Developer Setup & PR Checks
When you raise a PR, our GitHub Actions CI will automatically review your code for syntax, security, and vulnerabilities. To ensure your PR passes, please run these checks locally before pushing:

1. **Install dev dependencies:** 
   ```bash
   pip install flake8 bandit safety
   ```
2. **Run Linting (Flake8):** Checks for syntax errors and undefined names.
   ```bash
   flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
   ```
3. **Run Security Analysis (Bandit):** Checks for common security issues.
   ```bash
   bandit -r . -ll -ii
   ```
4. **Run Dependency Check (Safety):** Verifies no known vulnerabilities exist in dependencies.
   ```bash
   safety check -r requirements.txt
   ```
