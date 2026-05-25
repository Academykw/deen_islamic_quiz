import 'quiz_model.dart';

/// Stages for MVP — 5 stages per difficulty = 15 total
/// Each stage has 5 questions drawn from the seed list

const List<Stage> kEasyStages = [
  Stage(id: 'easy_s1', stageNumber: 1, difficulty: Difficulty.easy,
      questionIds: ['e001','e002','e003','e004','e005'],
      status: StageStatus.current),
  Stage(id: 'easy_s2', stageNumber: 2, difficulty: Difficulty.easy,
      questionIds: ['e006','e007','e008','e009','e010']),
  Stage(id: 'easy_s3', stageNumber: 3, difficulty: Difficulty.easy,
      questionIds: ['e001','e003','e005','e007','e009']),
  Stage(id: 'easy_s4', stageNumber: 4, difficulty: Difficulty.easy,
      questionIds: ['e002','e004','e006','e008','e010']),
  Stage(id: 'easy_s5', stageNumber: 5, difficulty: Difficulty.easy,
      questionIds: ['e001','e004','e006','e007','e010']),
];

const List<Stage> kMediumStages = [
  Stage(id: 'med_s1', stageNumber: 1, difficulty: Difficulty.medium,
      questionIds: ['m001','m002','m003','m004','m005'],
      status: StageStatus.current),
  Stage(id: 'med_s2', stageNumber: 2, difficulty: Difficulty.medium,
      questionIds: ['m006','m007','m008','m009','m010']),
  Stage(id: 'med_s3', stageNumber: 3, difficulty: Difficulty.medium,
      questionIds: ['m001','m003','m005','m007','m009']),
  Stage(id: 'med_s4', stageNumber: 4, difficulty: Difficulty.medium,
      questionIds: ['m002','m004','m006','m008','m010']),
  Stage(id: 'med_s5', stageNumber: 5, difficulty: Difficulty.medium,
      questionIds: ['m001','m004','m006','m008','m010']),
];

const List<Stage> kHardStages = [
  Stage(id: 'hard_s1', stageNumber: 1, difficulty: Difficulty.hard,
      questionIds: ['h001','h002','h003','h004','h005'],
      status: StageStatus.current),
  Stage(id: 'hard_s2', stageNumber: 2, difficulty: Difficulty.hard,
      questionIds: ['h006','h007','h008','h009','h010']),
  Stage(id: 'hard_s3', stageNumber: 3, difficulty: Difficulty.hard,
      questionIds: ['h001','h003','h005','h007','h009']),
  Stage(id: 'hard_s4', stageNumber: 4, difficulty: Difficulty.hard,
      questionIds: ['h002','h004','h006','h008','h010']),
  Stage(id: 'hard_s5', stageNumber: 5, difficulty: Difficulty.hard,
      questionIds: ['h001','h004','h006','h008','h010']),
];