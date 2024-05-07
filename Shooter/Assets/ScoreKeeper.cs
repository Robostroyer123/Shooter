using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using DG.Tweening;

public class ScoreKeeper : MonoBehaviour
{
    public GameObject streakParent;
    public TextMeshProUGUI scoreText;
    public Slider timer;
    public TextMeshProUGUI streakText;

    [Space]
    public bool killResetsStreak;
    public float killTimeIncrease = 0.5f;
    [Tooltip("How much time you have to kill to continue the streak.")] public float streakTimerCurve = 1;
    public float streakScoreMultiplier = 1.5f;
    public float scorePerKill = 100f;
    [Space]
    public float punchScale = 1.1f;
    public float punchDuration = 0.2f;

    float score;
    float scoreMultiplier;

    float timeSinceLastKill;
    float killStreak;
    float StreakTimer { get { return streakTimerCurve; } }
    public float TimeSinceLastKill { get { return timeSinceLastKill; } }
    public bool StreakActive { get { return 1 - (timeSinceLastKill / StreakTimer) > 0; } }
    private void Start()
    {
        UpdateText();
        timeSinceLastKill = Mathf.Infinity;
    }

    private void Update()
    {
        timeSinceLastKill += Time.deltaTime;
        if(timer != null) timer.value = Mathf.Clamp01(1 - (timeSinceLastKill / StreakTimer));
        if(!StreakActive)
        {
            killStreak = 0;
        }
        if(streakParent != null) streakParent.SetActive(StreakActive);
    }
    public void OnKill()
    {
        killStreak++;
        if (killResetsStreak)
        {
            timeSinceLastKill = 0;
        }
        else
        {
            timeSinceLastKill -= killTimeIncrease;
        }
        scoreMultiplier = streakScoreMultiplier;
        score += scorePerKill * scoreMultiplier;
        UpdateText();
    }

    void UpdateText()
    {
        if(scoreText != null)
            scoreText.SetText("Score: " + score);
        if (streakText != null)
        {
            streakText.SetText(killStreak.ToString());
            streakText.rectTransform.DOPunchScale(Vector3.one * punchScale, punchDuration, 1);
        }
    }
}
