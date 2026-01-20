import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Project from '../models/Project';
import CostConfig from '../models/CostConfig';
import Quote from '../models/Quote';
import logger from '../utils/logger';

dotenv.config();

const seedData = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/interior-design-db');
    logger.info('MongoDB Connected for Seeding');

    // Clear existing data
    await Project.deleteMany({});
    await CostConfig.deleteMany({});
    await Quote.deleteMany({});

    // Seed Cost Configs
    const costConfigs = await CostConfig.create([
      { category: 'Flooring', itemType: 'Hardwood Oak', basePrice: 120, unit: 'sqft', laborCostPerUnit: 40 },
      { category: 'Flooring', itemType: 'Ceramic Tile', basePrice: 80, unit: 'sqft', laborCostPerUnit: 35 },
      { category: 'Wall', itemType: 'Premium Paint', basePrice: 45, unit: 'sqft', laborCostPerUnit: 15 },
      { category: 'Wall', itemType: 'Wallpaper', basePrice: 60, unit: 'sqft', laborCostPerUnit: 25 },
    ]);

    logger.info('Cost Configs Seeded');

    // Seed Projects
    const project = await Project.create({
      title: 'Modern Living Room Renovation',
      clientName: 'Alice Johnson',
      clientEmail: 'alice@example.com',
      requirements: {
        roomType: 'Living Room',
        style: 'Modern',
        budget: 15000,
      },
      status: 'pending_approval',
    });

    logger.info('Projects Seeded');

    // Seed Quote
    await Quote.create({
      project: project._id as any,
      items: [
        {
          name: 'Hardwood Oak Flooring',
          category: 'Flooring',
          quantity: 200,
          unitPrice: 160, // base + labor
          totalPrice: 32000,
        },
      ],
      totalAmount: 32000,
      status: 'draft',
    });

    logger.info('Quotes Seeded');

    logger.info('Data Seeding Completed Successfully');
    process.exit(0);
  } catch (error) {
    logger.error(`Error Seeding Data: ${error}`);
    process.exit(1);
  }
};

seedData();
