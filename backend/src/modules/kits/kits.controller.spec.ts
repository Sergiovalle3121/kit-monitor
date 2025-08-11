import { Test, TestingModule } from '@nestjs/testing';
import { KitsController } from './kits.controller';

describe('KitsController', () => {
  let controller: KitsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [KitsController],
    }).compile();

    controller = module.get<KitsController>(KitsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
