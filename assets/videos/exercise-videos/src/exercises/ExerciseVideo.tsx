import React from 'react';
import { useCurrentFrame, useVideoConfig, interpolate } from 'remotion';

interface ExerciseStep {
  id: string;
  title: string;
  duration: number;
  category: string;
  bodyPart: string;
  description: string;
  steps: string[];
}

const categoryColors: Record<string, string> = {
  Seated: '#00F5FF',
  Standing: '#C084FC',
  Stretch: '#E8A87C',
  Strength: '#FF3366',
  Walk: '#34D399',
};

export const ExerciseVideo: React.FC<{ exercise: ExerciseStep }> = ({ exercise }) => {
  const frame = useCurrentFrame();
  const { durationInFrames, fps } = useVideoConfig();
  const seconds = frame / fps;
  const totalSeconds = durationInFrames / fps;
  const progress = Math.min(100, (seconds / totalSeconds) * 100);

  const catColor = categoryColors[exercise.category] || '#8B5CF6';

  const stepDuration = totalSeconds / (exercise.steps.length + 2);
  const currentStep = Math.min(
    exercise.steps.length - 1,
    Math.max(0, Math.floor((seconds - stepDuration * 0.5) / stepDuration))
  );

  const remaining = Math.max(0, Math.ceil(totalSeconds - seconds));
  const rm = Math.floor(remaining / 60);
  const rs = remaining % 60;

  const tOp = interpolate(frame, [0, 25], [0, 1], { extrapolateRight: 'clamp' });

  return (
    <div
      style={{
        width: 1080,
        height: 1920,
        backgroundColor: '#0B051A',
        color: '#FFFFFF',
        display: 'flex',
        flexDirection: 'column',
        fontFamily: 'Arial, sans-serif',
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      {/* BG blobs */}
      <div
        style={{
          position: 'absolute',
          top: -200,
          left: -100,
          width: 500,
          height: 500,
          borderRadius: '50%',
          background: catColor,
          opacity: 0.12,
          filter: 'blur(100px)',
          transform: `translate(${Math.sin(seconds * 0.3) * 30}px, ${Math.cos(seconds * 0.2) * 20}px)`,
        }}
      />
      <div
        style={{
          position: 'absolute',
          bottom: -150,
          right: -100,
          width: 400,
          height: 400,
          borderRadius: '50%',
          background: '#8B5CF6',
          opacity: 0.06,
          filter: 'blur(80px)',
        }}
      />

      {/* Top bar */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          padding: '40px 50px 0',
          opacity: tOp,
        }}
      >
        <div
          style={{
            padding: '10px 24px',
            borderRadius: 100,
            background: catColor + '20',
            border: `2px solid ${catColor}50`,
            color: catColor,
            fontSize: 20,
            fontWeight: 700,
            letterSpacing: 1,
          }}
        >
          {exercise.category.toUpperCase()}
        </div>
        <div
          style={{
            padding: '10px 24px',
            borderRadius: 100,
            background: 'rgba(255,255,255,0.06)',
            border: '2px solid rgba(255,255,255,0.1)',
            color: '#FFFFFF',
            fontSize: 24,
            fontWeight: 700,
          }}
        >
          {rm}:{rs.toString().padStart(2, '0')}
        </div>
      </div>

      {/* Title */}
      <div style={{ padding: '40px 50px 0', opacity: interpolate(frame, [10, 40], [0, 1], { extrapolateRight: 'clamp' }) }}>
        <div
          style={{
            display: 'inline-block',
            padding: '5px 14px',
            borderRadius: 8,
            background: catColor + '25',
            color: catColor,
            fontSize: 14,
            fontWeight: 600,
            marginBottom: 14,
          }}
        >
          {exercise.bodyPart}
        </div>
        <div style={{ fontSize: 48, fontWeight: 800, lineHeight: 1.15, marginBottom: 10 }}>
          {exercise.title}
        </div>
        <div style={{ fontSize: 22, color: '#B0A5C0', lineHeight: 1.4 }}>{exercise.description}</div>
      </div>

      {/* Progress bar */}
      <div
        style={{
          margin: '25px 50px',
          height: 5,
          borderRadius: 3,
          background: 'rgba(255,255,255,0.08)',
        }}
      >
        <div
          style={{
            width: `${progress}%`,
            height: '100%',
            borderRadius: 3,
            background: catColor,
            boxShadow: `0 0 10px ${catColor}80`,
            transition: 'width 0.3s',
          }}
        />
      </div>

      {/* Steps */}
      <div style={{ flex: 1, padding: '5px 50px', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
        {exercise.steps.map((step, i) => {
          const stepStart = stepDuration * (i + 0.5);
          const visible = seconds >= stepStart - 0.5;
          const active = i === currentStep;
          const done = i < currentStep;
          const appear = visible
            ? interpolate(frame, [Math.floor((stepStart - 0.5) * fps), Math.floor((stepStart + 0.4) * fps)], [0, 1], { extrapolateRight: 'clamp' })
            : 0;

          return (
            <div
              key={i}
              style={{ opacity: appear, transform: `translateY(${(1 - appear) * 15}px)`, marginBottom: 18, transition: 'all 0.3s' }}
            >
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 16 }}>
                <div
                  style={{
                    minWidth: 40,
                    height: 40,
                    borderRadius: '50%',
                    background: active ? catColor : done ? '#6B5B8B' : 'rgba(255,255,255,0.06)',
                    border: `2px solid ${active ? catColor : done ? '#6B5B8B' : 'rgba(255,255,255,0.1)'}`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    boxShadow: active ? `0 0 16px ${catColor}40` : 'none',
                    fontSize: 16,
                    fontWeight: 800,
                    color: '#FFFFFF',
                  }}
                >
                  {done ? '✓' : i + 1}
                </div>
                <div
                  style={{
                    flex: 1,
                    paddingTop: 8,
                    fontSize: active ? 26 : 22,
                    fontWeight: active ? 600 : 400,
                    lineHeight: 1.4,
                    color: active ? '#FFFFFF' : done ? '#6B5B8B' : '#B0A5C0',
                    textDecoration: done ? 'line-through' : 'none',
                  }}
                >
                  {step}
                </div>
              </div>
              {active && (
                <div
                  style={{
                    marginLeft: 56,
                    marginTop: 6,
                    height: 3,
                    borderRadius: 2,
                    background: `linear-gradient(90deg, ${catColor}, transparent)`,
                    width: `${Math.min(100, ((seconds - stepStart) / stepDuration) * 100)}%`,
                    maxWidth: '75%',
                    transition: 'width 0.5s',
                  }}
                />
              )}
            </div>
          );
        })}
      </div>

      {/* Bottom */}
      <div
        style={{
          padding: '0 50px 45px',
          opacity: remaining <= 5 ? interpolate(seconds, [totalSeconds - 5, totalSeconds - 2], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }) : 1,
        }}
      >
        <div
          style={{
            padding: '22px 28px',
            borderRadius: 16,
            background: 'rgba(255,255,255,0.04)',
            border: '2px solid rgba(255,255,255,0.08)',
            textAlign: 'center' as const,
          }}
        >
          <div style={{ fontSize: 22, fontWeight: 600, color: '#FFB800' }}>
            {remaining <= 0 ? 'Exercise complete. Great job.' : remaining < 60 ? 'Almost there. Keep going.' : 'You are doing amazing.'}
          </div>
        </div>
      </div>

      {/* Step dots */}
      <div style={{ position: 'absolute', right: 24, top: '45%', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {exercise.steps.map((_, i) => (
          <div
            key={i}
            style={{
              width: 10,
              height: 10,
              borderRadius: '50%',
              background: i < currentStep ? catColor : i === currentStep ? catColor : 'rgba(255,255,255,0.15)',
              boxShadow: i === currentStep ? `0 0 8px ${catColor}` : 'none',
              opacity: i === currentStep ? 1 : 0.6,
            }}
          />
        ))}
      </div>
    </div>
  );
};
