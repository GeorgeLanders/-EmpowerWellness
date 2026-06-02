import { Composition } from 'remotion';
import { ExerciseVideo } from './exercises/ExerciseVideo';
import { exercises } from './exercises/data';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {exercises.map((ex) => (
        <Composition
          key={ex.id}
          id={ex.id}
          component={() => <ExerciseVideo exercise={ex} />}
          durationInFrames={30 * ex.duration}
          fps={30}
          width={1080}
          height={1920}
        />
      ))}
    </>
  );
};
